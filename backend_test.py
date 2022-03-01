import requests
import base64
import json

api = 'https://3.144.236.126/findfaces/'
              
image_file = 'test_picture.png'

with open(image_file, "rb") as f:
    im_bytes = f.read()        
im_b64 = base64.b64encode(im_bytes).decode("utf8")

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
  
payload = json.dumps({"image": im_b64, "userid": "test_user"})
response = requests.post(api, data=payload, headers=headers, verify=False)
try:
    print(response.text)                
except requests.exceptions.RequestException:
    print(response.text)

# curl -X POST -d '{ "userid": "user1"}' --insecure https://3.144.236.126/findactor/ > /Users/tobycormack/Desktop/test.html    