from django.shortcuts import render
from pathlib import Path

# Create your views here.
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
import base64
import requests

import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from matplotlib.font_manager import json_dump
from PIL import Image 
import boto3

# This function sends a base64 encoded image to cloudVision to parse the image and detect faces
@csrf_exempt
def findfaces(request):
    # set environment variable
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/home/ubuntu/appetizers/superb-garden-342817-a513aa1e0d3e.json"
    from google.cloud import vision

    if request.method != 'POST':
        return HttpResponse(status=400)

    if not request.FILES.get("image") or not request.POST.get("userid"):
        return JsonResponse({"error": "no image?"})

    userid = request.POST["userid"]

    with request.FILES["image"] as f:
        im_bytes = f.read()
    content = base64.b64encode(im_bytes).decode("utf8")

    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=content)

    response = client.face_detection(image=image)
    faces = response.face_annotations

    return_resp = {"bounding_boxes": [], "userid": userid}
    for face in faces:
        return_resp["bounding_boxes"].append([])
        for vertex in face.bounding_poly.vertices:
            return_resp["bounding_boxes"][-1].append([vertex.x, vertex.y])

    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))

    return JsonResponse(return_resp)

@csrf_exempt
def findactor(request):
    if request.method != 'POST':
        return HttpResponse(status=400)

    # loading form-encoded data
    if not request.FILES.get("image") or not request.POST.get("userid") or not request.POST.get("bounding_box"):
        return JsonResponse({"error": "no image?"})
    userid = request.POST["userid"]
    content = request.FILES["image"]
    bounds = json.loads(request.POST["bounding_box"]) # [[a b] [c d] [e f] [g h]]

    filename = userid+str(time.time())+".png"
    fs = FileSystemStorage()

    filename = fs.save(filename, content)
    imageurl = fs.url(filename)

    # get coordinates from bounding box
    x_cords = []
    y_cords = []
    for bound in bounds:
        x_cords.append(bound[0])
        y_cords.append(bound[1])
    base_dir = Path(__file__).resolve().parent.parent 
    filename_full = base_dir / 'media' / filename
    img = Image.open(str(filename_full))

    # get right, left, top, bottom bounds
    x = min(x_cords)
    y = min(y_cords)
    w = max(x_cords) - min(x_cords)	
    h = max(y_cords) - min(y_cords)

    img_res = img.crop((x, y, x+w, y+h)) 
    img_res = img_res.save(filename_full)
    
    client=boto3.client('rekognition')

    with open(filename_full, 'rb') as image:
        api_response = client.recognize_celebrities(Image={'Bytes': image.read()})


    actorName = ""
    confidence = 0
    if len(api_response["CelebrityFaces"]) == 0:
        actorName = ""
    elif len(api_response["CelebrityFaces"]) > 1:
        max_conf = 0
        max_ind = -1
        counter = 0
        for tmp in api_response["CelebrityFaces"]:
            if tmp["MatchConfidence"] > max_conf:
                max_conf = tmp["MatchConfidence"]
                max_ind = counter
            counter = counter + 1

        actorName = api_response["CelebrityFaces"][max_ind]["Name"]
        confidence = max_conf
    else:
        actorName = api_response["CelebrityFaces"][0]["Name"]
        confidence = api_response["CelebrityFaces"][0]["MatchConfidence"]

    cursor = connection.cursor()
    cursor.execute('INSERT INTO history (userid, actor, imageurl, confidence) VALUES '
                   '(%s, %s, %s, %s);', (userid, actorName, imageurl, str(confidence)))

    response = {"actor": actorName, "confidence": confidence, "userid": userid, "url": imageurl}
    return JsonResponse(response)

@csrf_exempt
def getactorinfo(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    name = json_data['actorName']

    key = "k_ek29gjuf"
    findID_endpoint = "https://imdb-api.com/en/API/SearchName/" + key + "/" + name
    get_info_endpoint = "https://imdb-api.com/en/API/Name/" + key + "/"

    tmpResp = requests.get(findID_endpoint)
    jsonDict = json.loads(tmpResp.text)
    actorID = jsonDict["results"][0]["id"]

    response2 = requests.get(get_info_endpoint + actorID)
    jsonDict2 = json.loads(response.text)

    respArray = jsonDict2["castMovies"]

    def make_comparator_dict(less_than):
        def compareDict(x, y):
            if less_than(x, y):
                return -1
            elif less_than(y, x):
                return 1
            else:
                return 0
        return compareDict
    def lessThanDict(dict1, dict2):
        return int(dict1["year"]) < int(dict2["year"])

    sortedDict = sorted(respArray, cmp=make_comparator_dict(lessThanDict), reverse=True)

    response = {
        "name": name,
        "role": jsonDict2["role"],
        "summary": jsonDict2["summary"],
        "birthday": jsonDict2["birthDate"],
        "known_for": jsonDict2["knownFor"],
        "cast_movies": sortedDict,
        "image": jsonDict2["awards"],
        "awards":jsonDict2["image"]
    }


    return JsonResponse(response)

def getwatchlist(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    userid = json_data['userid']

    cursor = connection.cursor()
    cursor.execute('SELECT movietitle FROM watchlist WHERE userid=%s ORDER BY movietitle ASC;', (userid,))
    rows = cursor.fetchall()

    response = {'watchlist': []}
    for row in rows:
        response['watchlist'].append(row[0])
 
    return JsonResponse(response)

@csrf_exempt
def postwatchlist(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    userid = json_data['userid']
    movietitle = json_data['movietitle']
    cursor = connection.cursor()
    cursor.execute('INSERT INTO watchlist (userid, movietitle) VALUES ' '(%s, %s);', (userid, movietitle))
    return JsonResponse({})



def gethistory(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['chatts'] = ['Replace Me', 'DUMMY RESPONSE'] # **DUMMY response!**
    return JsonResponse(response)


def deletehistory(request):
    if request.method != 'DELETE':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    userid = json_data['userid']
    cursor = connection.cursor()
    cursor.execute('DELETE FROM history WHERE userid=?', (userid))
    response = json_data
    return JsonResponse(response)

def deletewatchlist(request):
    if request.method != 'DELETE':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    userid = json_data['userid']
    movietitle = json_data['movietitle']
    cursor = connection.cursor()
    cursor.execute('DELETE FROM watchlist WHERE userid=? AND movietitle=?', (userid, movietitle))
    response = json_data
    return JsonResponse(response)
