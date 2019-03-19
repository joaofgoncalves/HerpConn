

import arcpy
from arcpy import env
from arcpy.sa import *



# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

# Input direcory
# Subfolders with each model
inputDir = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\_tmp\\vars'
# Output direcotry
outDir = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\_tmp\\vars_1000m'

# Mask raster file
maskFile = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\DadosSolo\\Year2000\\rast2000.tif'
arcpy.env.extent = maskFile
arcpy.env.snapRaster = maskFile
arcpy.env.cellSize = maskFile
arcpy.env.outputCoordinateSystem = maskFile
arcpy.env.resamplingmethod = "NEAREST"

arcpy.env.workspace = inputDir

print(env.workspace)

rasterFileList = arcpy.ListRasters("*","TIF")


for rasterFile in rasterFileList:
    print("Processing file:" + rasterFile)
    arcpy.Resample_management(rasterFile, outDir + '\\' + rasterFile, maskFile, "NEAREST")
    print("done.\n")




