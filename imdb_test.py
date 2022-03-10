import requests
import base64
import json

key = "k_ek29gjuf"
findID_endpoint = "https://imdb-api.com/en/API/SearchName/" + key + "/"
get_info_endpoint = "https://imdb-api.com/en/API/Name/" + key + "/"


response = requests.get(findID_endpoint)
jsonD = json.loads(response.text)
actorID = jsonD["results"][0]["id"]
print('ActorID', actorID)
response2 = requests.get(get_info_endpoint + actorID)
jsonD2 = json.loads(response.text)
summary = jsonD2["summary"]
role = jsonD2["role"]
birthday = jsonD2["birthDate"]
known_for = jsonD2["knownFor"]
image = jsonD2["image"]
cast_movies = jsonD2["castMovies"]
awards = jsonD2["awards"]
print(response2.text)