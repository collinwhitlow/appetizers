from numpy import histogram
import requests
import base64
import json

image_file = 'test_2.jpeg'
api = 'https://3.144.236.126/findactor/'
headers = {'Accept': 'text/plain'}
files = {'image': open(image_file, 'rb')}

data = {"userid": "backend_test_2", "bounding_box": json.dumps([[993, 108], [1337, 108], [1337, 508], [993, 508]])}
response = requests.post(api, files=files, data=data, headers=headers, verify=False)
json_resp = response.json()
name = json.loads(response.text)["actor"]

import pdb
pdb.set_trace()
api = "https://3.144.236.126/gethistory/"
data = {"userid": "backend_test_2"}
historyResponse = requests.get(api, data=json.dumps(data), verify=False)
json_data = historyResponse.json()

assert("rows" in json_data)
assert(json_data["rows"][0][1] == name)

api = "https://3.144.236.126/deletehistory/"
data = {"userid": "backend_test_2", "actorName": name}
response = requests.delete(api, data=json.dumps(data), verify=False)
print(response.text)

api = "https://3.144.236.126/gethistory/"
data = {"userid": "backend_test_2"}
historyResponse = requests.get(api, data=json.dumps(data), verify=False)
json_data = historyResponse.json()

assert("rows" in json_data)
assert(len(json_data["rows"]) == 0)

api = 'https://3.144.236.126/postwatchlist/'
movie = "testMovie"
data = {"userid": "backend_test_2", "movietitle": movie}
response = requests.post(api, data=json.dumps(data), verify=False)

api = "https://3.144.236.126/getwatchlist/"
data = {"userid": "backend_test_2"}
historyResponse = requests.get(api, data=json.dumps(data), verify=False)
json_data = historyResponse.json()

assert("watchlist" in json_data)
assert(json_data["watchlist"][0] == movie)

api = "https://3.144.236.126/deletewatchlist/"
data = {"userid": "backend_test_2", "movietitle": movie}
response = requests.delete(api, data=json.dumps(data), verify=False)

api = "https://3.144.236.126/getwatchlist/"
data = {"userid": "backend_test_2"}
historyResponse = requests.get(api, data=json.dumps(data), verify=False)
json_data = historyResponse.json()

assert("watchlist" in json_data)
assert(len(json_data["watchlist"]) == 0)