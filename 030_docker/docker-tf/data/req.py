### author: twilts
### purpose: send request to tensorflow-serving
import requests
import json
import sys
import re

### prepare input parameters
params = sys.argv[2].split(" ")
lon = params[0]
lat = params[1]
speed = params[2]
volume = params[3]
celsius = params[4]

### somehow there is a space at the end of the ip address. remove it
ip = re.sub("[^0-9.]", "", sys.argv[1])
url = "http://"+ip+":8501/v1/models/boostedtree:classify"

### prepare the json send to classifier
data = json.dumps({"signature_name": "classification", "examples": [{"Latitude":float(lon),"Longitude":float(lat),"Speed":float(speed),"Volume":float(volume),"Celsius":float(celsius)}]})

### send request and print response
headers = {"content-type": "application/json"}
json_response = requests.post(url, data=data, headers=headers)
predictions = json_response.text
print(predictions)