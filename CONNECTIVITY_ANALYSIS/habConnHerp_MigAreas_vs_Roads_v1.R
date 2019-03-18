
library(sp)
library(spdep)
library(raster)
library(rgdal)
library(rgeos)


## --------------------------- ##


basePath<-"D:/MyDocs/Projects/Colab_ECivantos/data/ConnectMetrics/"

roads<-gBuffer(readOGR("D:/MyDocs/Projects/Colab_ECivantos/data/tmp","roads_osm_buff500m_Diss_v1",verbose=TRUE),TRUE,width=0)


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
    
    rstPath<-paste(basePath,sp,"/",scn,"/MultipleShortestPath_Sum_all.tif",sep="")
    MSPrst<-raster(rstPath)
    MSPrst[]<-as.integer(MSPrst[])
    
    cat("Processing",sp,scn,"........",sep=" | ")
    
    i<-i+1
    
    if(i==1){
      
      #rstRoads<-MSPrst
      #values(rstRoads)<-0
      #rstRoads<-rasterize(roads,rstRoads,1)
      #writeRaster(rstRoads,"D:/MyDocs/Projects/Colab_ECivantos/data/roads.tif")
    
      MSPvec<-rasterToPolygons(MSPrst,function(x){x>0},dissolve=FALSE)
      
    
    }
    
    int<-gIntersects(MSPvec,roads,byid=TRUE)

#     rstStack<-stack(MSPrst,rstRoads)
#     
#     tmp<-values(rstStack)
#     tmp[is.na(tmp[,2]),2]<-0
#     
#     mspDataList[[paste(sp,scn,"all",sep="_")]]<-log(tmp[tmp[,1]>0,1],base=2)
#     mspDataList[[paste(sp,scn,"roads",sep="_")]]<-log(tmp[tmp[,1]>0 & tmp[,2]==1,1],base=2)
#     
#     propIntRoads[i]<-(sum(tmp[tmp[,1]>0 & tmp[,2]==1]))/(sum(tmp[tmp[,1]>0,1]))
#     nm[i]<-paste(sp,scn,sep="_")
    
    cat("done.\n\n")
    
  }
}



## ------------ ##

MSPvec<-rasterToPolygons(MSPrst,dissolve=FALSE)

MSPvecpts<-rasterToPoints(MSPrst,spatial=TRUE)


writeOGR(MSPvec,"D:/MyDocs/Projects/Colab_ECivantos/data/MSP","MSP_vector","ESRI Shapefile")




par(mar=c(10,4,4,4))
boxplot(mspDataList,outline=FALSE,range=0.5,las=2,col=rep(c("white","light grey"),each=4))

