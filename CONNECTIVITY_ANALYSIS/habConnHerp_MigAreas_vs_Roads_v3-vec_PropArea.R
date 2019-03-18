

library(raster)
library(rgdal)
library(rgeos)


## --------------------------- ##


basePath<-"D:/MyDocs/Projects/Colab_ECivantos/data/ConnectMetrics/"

roads<-gBuffer(readOGR("D:/MyDocs/Projects/Colab_ECivantos/data/roads","roadsEP_Buffer500m_WGS84_29N_dissv2",verbose=TRUE),TRUE,width=0)


## --------------------------- ##

species<-c("ANGFR","BUCAL","CHALU","LACSH")
#species<-c("BUCAL","CHALU","LACSH")

quants<-c(0.05,0.5)

scenarios<-c("RCP26","RCP85")

nr<-length(species)*length(scenarios)*length(quants)
propProtectAreas<-matrix(nrow=nr,ncol=4,dimnames=list(1:nr,c("SPC","SCN","QTL","PROP")))
propProtectAreas<-as.data.frame(propProtectAreas)


## --------------------------- ##


i<-0
for(sp in species){
   
  for(scn in scenarios){
      
    rstPath<-paste(basePath,sp,"/",scn,"/MultipleShortestPath_Sum_all.tif",sep="")
    rst<-raster(rstPath)
    
    rst.val<-values(rst)
    
    rst.val<-rst.val[rst.val>0]
    
    for(p in quants){
       
      cat("Processing",sp,scn,p,"........",sep=" | ")
      
      i<-i+1
      
      #q<-quants
      q<-quantile(rst.val,prob=p,na.rm=TRUE)
      
      new.rst<-rst
      new.rst[rst<=q]<-NA
      new.rst[rst>q]<-1
      
      clumpMigAreas<-clump(new.rst)
      
      migAreasVector<-rasterToPolygons(clumpMigAreas,n=8,dissolve=TRUE)
      
      intVec<-gIntersection(migAreasVector,roads,TRUE)
      
      areas<-gArea(migAreasVector,TRUE)
      areasInt<-gArea(intVec,TRUE)
      
      prop<-sum(areasInt)/sum(areas)
      
      propProtectAreas[i,"SPC"]<-sp
      propProtectAreas[i,"SCN"]<-scn
      propProtectAreas[i,"QTL"]<-p
      propProtectAreas[i,"PROP"]<-prop
      
      cat("done.\n\n")
      
    }     
  }
}



write.csv(propProtectAreas,"D:/MyDocs/Projects/Colab_ECivantos/propRoads_vs_MigrationRoutes-ByQuant_v2.csv")


#save.image("D:/MyDocs/Projects/Colab_ECivantos/migRoutes_vs_protAreas.RData")
#load("D:/MyDocs/Projects/Colab_ECivantos/migRoutes_vs_protAreas.RData")

