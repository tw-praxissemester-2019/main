### author: twilts
### purpose: load the spark exported model and classify instance
### this script is called via REST API
from pypmml import Model
import sys

params = sys.argv[1].split(" ")
lon = params[0]
lat = params[1]
speed = params[2]
volume = params[3]
celsius = params[4]

model = Model.fromFile('/models/RF.pmml')
result = model.predict({'Longitude':lon,'Latitude':lat,'Speed':speed,'Volume':volume,'Celsius':celsius})
print(result)
