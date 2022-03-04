import requests
import base64
import json

# api = 'https://3.144.236.126/findfaces/'
              
# image_file = 'friends.jpeg'

# with open(image_file, "rb") as f:
#     im_bytes = f.read()        
# im_b64 = base64.b64encode(im_bytes).decode("utf8")

# headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
  
# payload = json.dumps({"image": im_b64, "userid": "test_user"})
# response = requests.post(api, data=payload, headers=headers, verify=False)
# try:
#     print(response.text)                
# except requests.exceptions.RequestException:
#     print(response.text)

# curl -X POST -d '{ "userid": "user1"}' --insecure https://3.144.236.126/findactor/ > /Users/tobycormack/Desktop/test.html

api = 'https://3.144.236.126/findactor/'
              
image_file = 'friends.jpeg'

with open(image_file, "rb") as f:
    im_bytes = f.read()        
im_b64 = base64.b64encode(im_bytes).decode("utf8")

headers = {'Accept': 'text/plain'}

files = {'image': open('friends.jpeg', 'rb')}

data = {"userid": "test_1_user", "bounding_box": [[620, 38], [716, 38], [716, 149], [620, 149]]}
response = requests.post(api, files=files, data=data, headers=headers, verify=False)
try:
    print(response.text)                
except requests.exceptions.RequestException:
    print(response.text)

# curl -X POST -d '{ "userid": "user1"}' --insecure https://3.144.236.126/findactor/ > /Users/tobycormack/Desktop/test.html    

# [[620, 38], [716, 38], [716, 149], [620, 149]]