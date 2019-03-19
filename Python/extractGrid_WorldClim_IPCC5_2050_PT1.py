import arcpy
from arcpy import env
from arcpy.sa import *
import glob
import os

# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")

# Input direcory
# Subfolders with each model
wdir = 'I:\\temp\\WorldClim_Bioclim2050_IPCC5_30ArcSec_WGS84'
# Output direcotry
outDir = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\WorldClim_IPCC5_2050_RCP85_PT1'

# Mask raster file
maskFile = 'D:\\MyDocs\\temp\\tmp_ECivantos\\data\\DadosSolo\\Year2000\\rast2000.tif'
arcpy.env.extent = maskFile
arcpy.env.snapRaster = maskFile
arcpy.env.cellSize = maskFile
arcpy.env.outputCoordinateSystem = maskFile
arcpy.env.geographicTransformations = "ED_1950_To_WGS_1984_PT7"
arcpy.env.resamplingmethod = "BILINEAR"

# Set local variables
dirList = os.listdir(wdir)

# Process directories
for i in range(len(dirList)):

    print("-> Reading files...")

    fileList = os.listdir(wdir + '\\' + dirList[i])

    newpath = outDir + '\\' + dirList[i] + '_PT1_ED50_29N_1km'

    print("-> Creating new directory:\n",newpath)

    if not os.path.exists(newpath): os.makedirs(newpath)

    for j in range(len(fileList)):

        if fileList[j].endswith(".tif"):

            rstFile = wdir + '\\' + dirList[i] + '\\' + fileList[j]

            print("Working on file: " + fileList[j])
            arcpy.outExtractByMask = ExtractByMask(rstFile, maskFile)
            arcpy.outExtractByMask.save(newpath + '\\' + fileList[j])
            print("Done.\n")




