import requests
import base64
import json

api = 'https://3.144.236.126/findfaces/'
              
image_file = 'test_2.jpeg'

headers = {'Accept': 'text/plain'}

files = {'image': open(image_file, 'rb')}

data = {"userid": "959B4E3F-22E2-4B00-8EC8-8522BF375D03"}
response = requests.post(api, files=files, data=data, headers=headers, verify=False)
try:
    print(response.text)                
except requests.exceptions.RequestException:
    print(response.text)

# curl -X POST -d '{ "userid": "user1"}' --insecure https://3.144.236.126/findactor/ > /Users/tobycormack/Desktop/test.html

new_data = json.loads(response.text)

api = 'https://3.144.236.126/findactor/'
              
headers = {'Accept': 'text/plain'}

files = {'image': open(image_file, 'rb')}

data = {"userid": "959B4E3F-22E2-4B00-8EC8-8522BF375D03", "bounding_box": json.dumps(new_data["bounding_boxes"][1])}
response = requests.post(api, files=files, data=data, headers=headers, verify=False)
try:
    print(response.text)
except requests.exceptions.RequestException:
    print(response.text)

name = json.loads(response.text)["actor"]
# name = "Chadwick Boseman"
api = "https://3.144.236.126/getactorinfo/"
data = {"userid": "959B4E3F-22E2-4B00-8EC8-8522BF375D03", "actorName": name}
response = requests.post(api, data=json.dumps(data), verify=False)
print(response.text)




# curl -X POST -d '{ "userid": "user1"}' --insecure https://3.144.236.126/findactor/ > /Users/tobycormack/Desktop/test.html    

# [[620, 38], [716, 38], [716, 149], [620, 149]]
