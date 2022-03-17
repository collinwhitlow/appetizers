import requests
import base64
import json

key = "k_ek29gjuf"
# findID_endpoint = "https://imdb-api.com/en/API/SearchName/" + key + "/"
# get_info_endpoint = "https://imdb-api.com/en/API/Name/" + key + "/"


# response = requests.get(findID_endpoint)
# jsonD = json.loads(response.text)
# actorID = jsonD["results"][0]["id"]
# print('ActorID', actorID)
# response2 = requests.get(get_info_endpoint + actorID)
# jsonD2 = json.loads(response.text)
# summary = jsonD2["summary"]
# role = jsonD2["role"]
# birthday = jsonD2["birthDate"]
# known_for = jsonD2["knownFor"]
# image = jsonD2["image"]
# cast_movies = jsonD2["castMovies"]
# awards = jsonD2["awards"]
# print(response2.text)

# title_endpoint =  "https://imdb-api.com/en/API/Title/" + key + "/tt1667889"
# title_endpoint2 = "https://imdb-api.com/en/API/SearchTitle/" + key + "/inception"
# tmpResp = requests.get(title_endpoint2)
# jsonDict = json.loads(tmpResp.text)
# print(tmpResp.text)


api = 'https://3.144.236.126/postwatchlist/'
movie = "Finding Nemo"
data = {"userid": "959B4E3F-22E2-4B00-8EC8-8522BF375D03", "movietitle": movie, "imageURL": ""}
response = requests.post(api, data=json.dumps(data), verify=False)
print(response.text)
