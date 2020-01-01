### author: TWilts
### purpose: print json with values for windspeed, temperature and precipitation for a given month and lat,lon
import numpy as np
import json
import linecache
import re
import sys

### function to determine column in ascii grid
def getX(x,cols):
    with open('/config_data/map_section.json') as json_file:
        bounds = json.load(json_file)
    x_start = bounds['map']['xmin']
    x_end = bounds['map']['xmax']
    x_difference = x_start - x_end
    x_step = abs(x_difference) / int(cols)
    x_grid = round(abs(x_start - x) / x_step)
    return x_grid

### function to determine row in ascii grid
def getY(y,rows):
    with open('/config_data/map_section.json') as json_file:
        bounds = json.load(json_file)
    y_start = bounds['map']['ymin']
    y_end = bounds['map']['ymax']
    y_difference = y_start - y_end
    y_step = abs(y_difference) / float(rows)
    y_grid = round(abs(y_start - y) / y_step)
    return y_grid

res_dict = dict()
month = sys.argv[1]
# lon is negative
longitude = float(sys.argv[2])
latitude = float(sys.argv[3])
### fill lat,lon into dictionary
res_dict['Latitude'] = latitude
res_dict['Longitude'] = longitude

### linecache is to read only a single line into cache without having to read the complete file into memory
### it returs a string with all values in one line so it has to be split
### Get Windspeed
pathToGrid = "/grid_data/wc2/grids/"+month+"/out"+month+".asc"
cols = re.split(r'\s+', linecache.getline(pathToGrid, 1))[1]
rows = re.split(r'\s+', linecache.getline(pathToGrid, 2))[1]
val = linecache.getline(pathToGrid, int(getY(latitude,rows)+6)).split(" ")[int(getX(longitude,cols))]
res_dict['Speed'] = val

### Get Precipitation
pathToGrid = "/grid_data/wc2-2/grids/"+month+"/out"+month+".asc"
cols = re.split(r'\s+', linecache.getline(pathToGrid, 1))[1]
rows = re.split(r'\s+', linecache.getline(pathToGrid, 2))[1]

val = linecache.getline(pathToGrid, int(getY(latitude,rows)+6)).split(" ")[int(getX(longitude,cols))]
res_dict['Precipitation'] = val

### Get Temperature
pathToGrid = "/grid_data/wc2-3/grids/"+month+"/out"+month+".asc"
cols = re.split(r'\s+', linecache.getline(pathToGrid, 1))[1]
rows = re.split(r'\s+', linecache.getline(pathToGrid, 2))[1]

val = linecache.getline(pathToGrid, int(getY(latitude,rows)+6)).split(" ")[int(getX(longitude,cols))]

res_dict['Celsius'] = val

### print json-string
print(str(res_dict['Latitude'])+" "+str(res_dict['Longitude'])+" "+str(res_dict['Speed'])+" "+str(res_dict['Precipitation'])+" "+str(res_dict['Celsius']))