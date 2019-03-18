
library(raster)

setwd("D:/MyDocs/temp/colab_EC/dem_zonal")

rstDEM<-raster("dem_srtm80m.tif")

rstZones<-raster("grid1000m.tif")


zonQ25<-zonal(rstDEM,rstZones,fun=function(x,...) quantile(x,probs=0.25,...),na.rm=TRUE)
zonQ75<-zonal(rstDEM,rstZones,fun=function(x,...) quantile(x,probs=0.75,...),na.rm=TRUE)

zon<-merge(zonQ25,zonQ75,by="zone")

zon<-cbind(zon,iqr=zon[,3]-zon[,2])

write.csv(zon,"zonal_IQR_DEM_SRTM.csv")