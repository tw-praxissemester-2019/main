#!/bin/bash

# author: TWilts
# purpose: automated cutting (only USA) and converting to ESRI shapefile

# adjust your path to gdal_polygenize eventually
pathToGDAL="/usr/local/Cellar/gdal/2.4.2/bin/"

# =====================================
# If you cloned the repository, you sholdn't need to change anything here

function cutStuff {
    folder=$1"*"
    mkdir $1"grids"
    index=1
    # parse the json file
    xmin=$(cat 070_config/map_section.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["map"]["xmin"])')
    ymin=$(cat 070_config/map_section.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["map"]["ymin"])')
    xmax=$(cat 070_config/map_section.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["map"]["xmax"])')
    ymax=$(cat 070_config/map_section.json | python -c 'import json,sys;obj=json.load(sys.stdin);print(obj["map"]["ymax"])')
    for file in $folder
    do
        if [[ $file =~ \.tif ]]
        then  
            mkdir $1"grids/"$index
            gdal_translate -projwin $xmin $ymax $xmax $ymin $file $1"grids/"$index"/"cutted.tif
            gdal_translate -of AAIGrid $1"grids/"$index"/"cutted.tif $1"grids/"$index"/"out$index.asc
            #python $2"gdal_polygonize.py" $1"shapefiles/"$index"/"cutted.tif -f "ESRI Shapefile" $1"shapefiles/"$index"/"file.shp
            rm $1"grids/"$index"/"cutted.tif
            index=$[index+1]
        fi
    done
}

# load map section

# do cutting
cutStuff "010_data/wc2/" $pathToGDAL
cutStuff "010_data/wc2-2/" $pathToGDAL
cutStuff "010_data/wc2-3/" $pathToGDAL
