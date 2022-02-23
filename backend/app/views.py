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
    username = request.POST.get("userid")

    if request.FILES.get("image"):
        content = request.FILES['image']
        filename = username+str(time.time())+".jpeg"
        fs = FileSystemStorage()
        filename = fs.save(filename, content)
        imageurl = fs.url(filename)
    else:
        imageurl = None

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

    actorName = ""
    cursor = connection.cursor()
    cursor.execute('INSERT INTO history (userid, actor, imageurl) VALUES '
                   '(%s, %s, %s);', (userid, actorName, imageurl))

    return JsonResponse({})


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