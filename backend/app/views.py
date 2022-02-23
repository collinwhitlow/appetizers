from django.shortcuts import render

# Create your views here.
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json

import os, time
from django.conf import settings
from django.core.files.storage import FileSystemStorage

@csrf_exempt
def findfaces(request):
    if request.method != 'POST':
        return HttpResponse(status=400)

    # loading form-encoded data
    userid = request.POST.get("userid")

    if request.FILES.get("image"):
        content = request.FILES['image']
        filename = userid+str(time.time())+".jpeg"
    else:
        return HttpResponse(status=400)
    content
    filename
    # todo, submit the image parse the response and get the name out

    return JsonResponse({})

@csrf_exempt
def findactor(request):
    if request.method != 'POST':
        return HttpResponse(status=400)

    # loading form-encoded data
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
    test1 = {"CelebrityFaces": [{"KnownGender": { "Type": "Male"},"MatchConfidence": 98.0,"Name": "Jeff Bezos", "Urls": ["www.imdb.com/name/nm1757263"]}]}
    #test2 = {"CelebrityFaces": []}
    #test3 = {"CelebrityFaces": [{"KnownGender": { "Type": "Male"},"MatchConfidence": 98.0,"Name": "Jeff Bezos", "Urls": ["www.imdb.com/name/nm1757263"]}, {"KnownGender": { "Type": "Male"},"MatchConfidence": 94.0,"Name": "NOT BESSOS", "Urls": ["www.imdb.com/name/nm1757263"]}, {"KnownGender": { "Type": "Male"},"MatchConfidence": 99.0,"Name": "Jefff", "Urls": ["www.imdb.com/name/nm1757263"]}]}

    
    api_response = test1
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

    response = {"actor": actorName, "confidence": confidence, "image": "SOMEHOW RETURN AN IMAGE"}
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