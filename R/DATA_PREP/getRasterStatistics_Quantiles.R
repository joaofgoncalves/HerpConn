
require(raster)


q05<-function(x,...) quantile(x,probs=0.05,...)
q25<-function(x,...) quantile(x,probs=0.25,...)
q75<-function(x,...) quantile(x,probs=0.75,...)
q95<-function(x,...) quantile(x,probs=0.95,...)

#zonalGrid<-raster("D:/MyDocs/temp/tmp_ECivantos/data/_tmp/_zonal_LULC_grid_1km_ed50_29n.tif")
#slopeGrid<-raster("D:/MyDocs/temp/tmp_ECivantos/data/_tmp/slope_percPT1_SRTMv4_ED50_29N.tif")

twiGrid<-raster("D:/MyDocs/temp/tmp_ECivantos/data/hidro/TWI_PT1_ED50_29N.tif")
catchAreaGrid<-raster("D:/MyDocs/temp/tmp_ECivantos/data/hidro/ModCatchmentArea_PT1_ED50_29N.tif")


funs<-c("min","max","q05","q25","q75","q95","mean","median","sd")


for(f in funs){
  
  cat("Processing function: [",f,"] .....")
  
  tmp1<-aggregate(twiGrid, 11, fun=eval(parse(text=f)))
  writeRaster(tmp1,paste("D:/MyDocs/temp/tmp_ECivantos/data/_tmp/twi_",f,"_pix990m_ED50_29N.tif",sep=""))
  
  tmp2<-aggregate(catchAreaGrid, 11, fun=eval(parse(text=f)))
  writeRaster(tmp2,paste("D:/MyDocs/temp/tmp_ECivantos/data/_tmp/catchArea_",f,"_pix990m_ED50_29N.tif",sep=""))
  
  cat("done.\n\n")
  
}


