from django.shortcuts import render

# Create your views here.
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json

import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage
# This function sends a base64 encoded image to cloudVision to parse the image and detect faces
@csrf_exempt
def findfaces(request):
    # set environment variable
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/home/ubuntu/appetizers/superb-garden-342817-a513aa1e0d3e.json"
    from google.cloud import vision

    if request.method != 'POST':
        return HttpResponse(status=400)

    # loading form-encoded data
    userid = request.POST.get("userid")

    if not request.POST.get("image"):
        return HttpResponse(status=400)
             
    # get the base64 encoded string
    content = request.POST.get("image")

    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=content)

    response = client.face_detection(image=image)
    faces = response.face_annotations

    return_resp = {"bounding_boxes": []}
    for face in faces:
        for vertex in face.bounding_poly.vertices:
            return_resp["bounding_boxes"].append([vertex.x, vertex.y])

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
    # FIXME, this is not working for some reason, all the users are null -- could be that im using curl... not sure
    userid = request.POST.get("userid")

    if request.FILES.get("image"):
        content = request.FILES['image']
        filename = userid+str(time.time())+".jpeg"
        fs = FileSystemStorage()
        filename = fs.save(filename, content)
        imageurl = fs.url(filename)
    else:
        imageurl = None


    # submit the photo, get the name back 
    # TODO
    # test1 = {"CelebrityFaces": [{"KnownGender": { "Type": "Male"},"MatchConfidence": 98.0,"Name": "Jeff Bezos", "Urls": ["www.imdb.com/name/nm1757263"]}]}
    # test2 = {"CelebrityFaces": []}
    test3 = {"CelebrityFaces": [{"KnownGender": { "Type": "Male"},"MatchConfidence": 98.0,"Name": "Jeff Bezos", "Urls": ["www.imdb.com/name/nm1757263"]}, {"KnownGender": { "Type": "Male"},"MatchConfidence": 94.0,"Name": "NOT BESSOS", "Urls": ["www.imdb.com/name/nm1757263"]}, {"KnownGender": { "Type": "Male"},"MatchConfidence": 99.0,"Name": "Jefff", "Urls": ["www.imdb.com/name/nm1757263"]}]}

    
    api_response = test3
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
    cursor.execute('INSERT INTO history (userid, actor, imageurl) VALUES '
                   '(%s, %s, %s);', (userid, actorName, imageurl))

    response = {"actor": actorName, "confidence": confidence, "image": "SOMEHOW RETURN AN IMAGE", "userid": userid}
    return JsonResponse(response)


def getactorinfo(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['chatts'] = ['Replace Me', 'DUMMY RESPONSE'] # **DUMMY response!**
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


def postwatchlist(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['chatts'] = ['Replace Me', 'DUMMY RESPONSE'] # **DUMMY response!**
    return JsonResponse(response)


def gethistory(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['chatts'] = ['Replace Me', 'DUMMY RESPONSE'] # **DUMMY response!**
    return JsonResponse(response)


def deletehistory(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['chatts'] = ['Replace Me', 'DUMMY RESPONSE'] # **DUMMY response!**
    return JsonResponse(response)

def deletewatchlist(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['chatts'] = ['Replace Me', 'DUMMY RESPONSE'] # **DUMMY response!**
    return JsonResponse(response)