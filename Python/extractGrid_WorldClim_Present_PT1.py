import arcpy
from arcpy import env
from arcpy.sa import *



# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

# Input direcory
# Subfolders with each model
wdir = 'I:\\GeoData\\ByTheme\\ClimMeteoAtm\\WorldClimData\\v0\\W\\ArcGrid\\bio_30s_esri'
# Output direcotry
outDir = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\WorldClim_Present'

# Mask raster file
maskFile = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\DadosSolo\\Year2000\\rast2000.tif'
arcpy.env.extent = maskFile
arcpy.env.snapRaster = maskFile
arcpy.env.cellSize = maskFile
arcpy.env.outputCoordinateSystem = maskFile
arcpy.env.geographicTransformations = "ED_1950_To_WGS_1984_PT7"
arcpy.env.resamplingmethod = "BILINEAR"

# Define input data as the workspace
arcpy.env.workspace = wdir

# List all raster files in the work directory
rasterList = arcpy.ListRasters("*", "GRID")

# Process directories
for rasterFile in rasterList:

    print("Working on file: " + rasterFile)
    arcpy.outExtractByMask = ExtractByMask(rasterFile, maskFile)
    arcpy.outExtractByMask.save(outDir + '\\' + rasterFile + '.tif')
    print("Done.\n")



