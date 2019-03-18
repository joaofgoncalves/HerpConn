
library(raster)


basePath<-"D:/MyDocs/Projects/Colab_ECivantos/data/ConnectMetrics"

fl<-list.files(basePath,recursive=TRUE,full.names=TRUE)

idx<-grep("MultipleShortestPath_Sum_all.tif$",fl)

fl<-fl[idx]

fl<-c(fl,"D:/MyDocs/My Dropbox/SharedWorkFolder/FCA/data/_SPDATA/roads_ep_1000m_WGS84UTM29N_v1.tif")

rstStack<-raster::stack(fl)
rstStackDF<-values(rstStack)

colnames(rstStackDF)<-c(paste("SPsum",rep(c("ANGFR","BUCAL","CHALU","LACSH"),each=2), 
                              rep(c("RCP26","RCP85"),4),sep="_"),"roadsEP_perc")

for(i in 1:(ncol(rstStackDF)-1)){

  rstStackDF[rstStackDF[,i]==0,i]<-NA

}

## ------------------------------------------------------------------ ##

SpearmanCorSPsumRoadPerc<-as.data.frame(matrix(nrow=8,ncol=3))

for(i in 1:(ncol(rstStackDF)-1)){
  
  tmp<-rstStackDF[,c(i,9)]
  tmp<-tmp[!is.na(tmp[,1]),]
  
  tmp.cor<-cor.test(tmp[,1],tmp[,2],method="spearman")
  
  SpearmanCorSPsumRoadPerc[i,1]<-colnames(tmp)[1]
  SpearmanCorSPsumRoadPerc[i,2]<-tmp.cor[["estimate"]]
  SpearmanCorSPsumRoadPerc[i,3]<-tmp.cor[["p.value"]]
  
}


