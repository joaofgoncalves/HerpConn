

require(raster)
require(sp)



source("D:/MyDocs/Dev-Eclipse/Projects-Workspace/Misc/_Global_Utils/StringHandling.R")

rasterList<-list.files("D:/MyDocs/temp/tmp_ECivantos/data/WorldClim_IPCC5_2050_RCP85_PT1",
                        full.names=TRUE,recursive=TRUE,pattern=".tif$")

outDir<-"D:/MyDocs/temp/tmp_ECivantos/data/WorldClim_IPCC5_2050_RCP85_PT1_Cons"


for(i in 1:2){
  
  cat("-> Processing bioclimatic index #",i,"......\n")
  
  getInd<-paste("i50",i,".tif$",sep="")
  ind<-grep(getInd,rasterList)
  
  cat("Reading data ....")
  rstStack<-stack(rasterList[ind]) 
  rstData<-getValues(rstStack)
  cat("done.\n")
  
  cat("Calculating statistics ....")
  rstMD<-apply(rstData,1,median)
  rstMN<-apply(rstData,1,mean)
  rstSD<-apply(rstData,1,sd)
  cat("done.\n")
  
  cat("Creating new rasters ....")
  newRstMD<-raster(rstStack,layer=0)
  newRstMN<-raster(rstStack,layer=0)
  newRstSD<-raster(rstStack,layer=0)
  
  newRstMD<-setValues(newRstMD,rstMD)
  newRstMN<-setValues(newRstMD,rstMN)
  newRstSD<-setValues(newRstMD,rstSD)
  
  writeRaster(newRstMD,paste(outDir,"/BioClim",pad.number(i,10),"_IPCC5_ConsMD_1km_ED50_29N.tif",sep=""))
  writeRaster(newRstMN,paste(outDir,"/BioClim",pad.number(i,10),"_IPCC5_ConsMN_1km_ED50_29N.tif",sep=""))
  writeRaster(newRstSD,paste(outDir,"/BioClim",pad.number(i,10),"_IPCC5_ConsSD_1km_ED50_29N.tif",sep=""))
  cat("done.\n")
  
  cat("Finished processing file.\n\n\n")
  
}


