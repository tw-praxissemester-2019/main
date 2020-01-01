import requests
import json
github_url = "http://192.168.2.104:8501/v1/models/boostedtree:classify"

data = json.dumps({"signature_name": "classification", "examples": [{"Latitude":-142.4,"Longitude":87.3,"Speed":12.4,"Volume":18.4,"Celsius":35.4}]})
print(data)
# headers = {"content-type": "application/json"}
# json_response = requests.post(github_url, data=data, headers=headers)
# predictions = json_response.text
# print(predictions)