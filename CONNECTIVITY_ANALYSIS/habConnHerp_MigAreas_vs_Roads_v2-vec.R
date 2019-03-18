

library(sp)
library(raster)
library(rgdal)
library(rgeos)


## --------------------------- ##


basePath<-"D:/MyDocs/Projects/Colab_ECivantos/data/ConnectMetrics/"

roads<-gBuffer(readOGR("D:/MyDocs/Projects/Colab_ECivantos/data/roads","roadsEP_Buffer500m_WGS84_29N_dissv2",verbose=TRUE),TRUE,width=0)


## --------------------------- ##

species<-c("ANGFR","BUCAL","CHALU","LACSH")

scenarios<-c("RCP26","RCP85")

## --------------------------- ##


mspDataList<-list()
propIntRoads<-c()
nm<-c()
i<-0


for(sp in species){
  
  for(scn in scenarios){
    
    i<-i+1
    
    cat("Processing",sp,scn,"........",sep=" | ")
    
    
    rstPath<-paste(basePath,sp,"/",scn,"/MultipleShortestPath_Sum_all.tif",sep="")
    MSPrst<-raster(rstPath)
    MSPrst[]<-as.integer(MSPrst[])
    
    
    # All values greater than 0 (whole area)
    tmp<-values(MSPrst)
    mspDataList[[paste(sp,scn,"all",sep="_")]]<-log(tmp[tmp>0],base=2)
    
    # Values intersected by roads
    MSPvec<-rasterToPolygons(MSPrst,function(x){x>0},dissolve=FALSE)
    int<-gIntersects(MSPvec,roads,byid=TRUE)
    mspDataList[[paste(sp,scn,"roads",sep="_")]]<-log(MSPvec@data@.Data[[1]][int[3,]],base=2)

    
    
    cat("done.\n\n")
    
  }
}



## ------------ ##

MSPvec<-rasterToPolygons(MSPrst,dissolve=FALSE)

MSPvecpts<-rasterToPoints(MSPrst,spatial=TRUE)


writeOGR(MSPvec,"D:/MyDocs/Projects/Colab_ECivantos/data/MSP","MSP_vector","ESRI Shapefile")




par(mar=c(10,4,4,4))
boxplot(mspDataList,outline=FALSE,range=0.5,las=2,col=rep(c("white","light grey"),each=4))

