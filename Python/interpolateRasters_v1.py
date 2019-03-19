

import glob
import arcgisscripting
gp = arcgisscripting.create(10.0)

gp.AddToolbox("C:/Program Files/GeoEco/ArcGISToolbox/Marine Geospatial Ecology Tools.tbx")

#spCodes = ["BUCAL","LACLE","PODHP","SALAM"]
spCodes = ["ANGFR"]


baseDir = "D:/MyDocs/temp/tmp_ECivantos/data"

projDirs = ["RCP26_2050","RCP85_2050"]

for sp in spCodes:

    for projDir in projDirs:

        workDir = baseDir + "/" + sp + "/proj_" + projDir

        fileList = glob.glob(workDir + "/*.tif")


        for inRaster in fileList:

            inRaster = inRaster.replace("\\","/")
            fname = inRaster.split("/")
            fname = fname[len(fname)-1]
            fname = fname.replace(".tif","")

            outRaster = workDir + "/" + fname + "_intDel2a.tif"

            print("Processing file:" + inRaster + "...........\n")

            gp.InterpolatorInpaintArcGISRaster_GeoEco(inRaster, outRaster, "Del2a", 50, "#")

            print("done.\n")

