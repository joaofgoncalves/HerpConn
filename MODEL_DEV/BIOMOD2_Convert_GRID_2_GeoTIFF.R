

# ---------------------------------------------------------------------------------------------- #
# Converts each band in GRID files (corresponding to each model used in ensembling) into GeoTIFF
# ---------------------------------------------------------------------------------------------- #


rm(list=ls())

require(biomod2)
require(raster)

# !!! Change the working directory according to your system
setwd("D:/MyDocs/temp/tmp_ECivantos/data")

# Projection names and species codes used
projNames<-c("Current","RCP26_2050","RCP85_2050")
spCodes<-c("BUCAL","LACLE","PODHP","SALAM")


for(sp in spCodes){
  
  # Load the ensemble object and get models used in ensembling for each species
  load(paste(sp,"_BIOMOD2_ensembleObj_v2_ROC.RData",sep=""))
  mods<-get_kept_models(ensembleObj,model=1)
  
  # Iterate by each projection name
  for(projName in projNames){
    
    
    rst<-raster(paste(getwd(),"/",sp,"/proj_",projName,"/proj_",projName,"_",sp,".grd",sep=""))
    nb<-nbands(rst)
    dir.create(paste(getwd(),"/",sp,"/proj_",projName,"/proj_",projName,sep=""))
    
    for(i in 1:nb){
      
      cat(sp,projName,mods[i],"..........",sep=" | ")
      
      rst<-raster(paste(getwd(),"/",sp,"/proj_",projName,"/proj_",projName,"_",sp,".grd",sep=""),band=i)
      
      writeRaster(rst,filename=paste(getwd(),"/",sp,"/proj_",projName,"/proj_",projName,"/",sp,"_",projName,"_",mods[i],".tif",sep=""))
      
      cat("done.\n\n")
      
    } 
  }
}






