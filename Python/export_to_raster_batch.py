


# Import system modules
import arcpy
from arcpy import env

# Set environment settings
env.workspace = "D:/MyDocs/temp/tmp_ECivantos/data/var_spData"

# Set local variables
# inFeatures = "PredVars_UTM1kmGrid_WGS84_UTM29N.shp"
inFeatures = "D:/MyDocs/temp/tmp_ECivantos/data/_spData/geodb/spDataMods.gdb/spData_vars1km_wgs84_29n"

fields = arcpy.ListFields(inFeatures)
cellSize = 1000

for field in fields[5:]:

    valField = str(field.name)
    outRaster = valField + "_WGS84_UTM29N.tif"
    print "Converting field: " + valField + "......"

    # Execute PolygonToRaster
    arcpy.PolygonToRaster_conversion(inFeatures, valField, outRaster, cellsize=cellSize)
    print "done.\n"

