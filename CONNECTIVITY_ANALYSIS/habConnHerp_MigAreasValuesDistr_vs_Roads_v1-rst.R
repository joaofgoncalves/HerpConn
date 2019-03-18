

library(sp)
library(raster)
library(rgdal)
library(rgeos)
library(stringr)
library(ggplot2)

## --------------------------- ##


basePath<-"D:/MyDocs/Projects/Colab_ECivantos/data/ConnectMetrics/"


roadsPercRst<-raster("D:/MyDocs/Projects/Colab_ECivantos/data/roads_rst/roads_ep_1000m_WGS84UTM29N_v1.tif")

## --------------------------- ##

species<-c("ANGFR","LACSH","CHALU","BUCAL")

spNames<-c("A. fragilis","L. schreiberi","C. lusitanica","E. calamita")
names(spNames)<-species

scenarios<-c("RCP26","RCP85")

scn_name<-c("LES","HES")
names(scn_name)<-scenarios

outDirPlots<-"D:/MyDocs/temp/colab_EC"

## --------------------------- ##

rstValList<-list()
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
    
    rstStack<-stack(roadsPercRst,MSPrst)
    
    tmpValuesDF<-values(rstStack)
    
    rstValList[[paste(spNames[sp],scn_name[scn],"ALL",sep="_")]]<-tmpValuesDF[tmpValuesDF[,2] >= 5, 2]
    rstValList[[paste(spNames[sp],scn_name[scn],"MOT",sep="_")]]<-tmpValuesDF[(tmpValuesDF[,1] >= 0.05 & tmpValuesDF[,2] >= 5),2]
    
    
    cat("done.\n\n")
    
  }
}



tiff(file=paste(outDirPlots,"/motorways_vs_MigCorridors.tif",sep=""),compression="lzw",res=600,height=6500,width=6600)

par(mar=c(12,5,2,2))
boxplot(rstValList,outline=TRUE,range=2,las=2,
        col=rep(c("white","light grey"),each=2),
        cex.lab=1.2, cex.axis=1.2,log="y",ylab="SPsum values")
dev.off()



## ---------------------------------------------------------------------------------------- ##



nm<-names(rstValList)
#strsplit(nm,"_")

DF<-data.frame(grp1=rep(nm,time=sapply(rstValList,length)),Spsum=unlist(rstValList))
rownames(DF)<-1:nrow(DF)

zz<-strsplit(as.character(DF[,1]),"_")
zz<-unlist(zz)

DF<-data.frame(DF[,1],matrix(zz,nrow=nrow(DF),ncol=3,byrow = TRUE),DF[,2])
colnames(DF)<-c(paste("grp",1:4,sep=""),"SPsum")

DF<-cbind(DF,grp5=paste(DF[,"grp2"],DF[,"grp4"],sep="_"))

DF[,"grp3"]<-factor(DF[,"grp3"],levels = c('LES','HES'),ordered = TRUE)

DF[,"grp2"]<-factor(DF[,"grp2"],levels = c("A. fragilis","L. schreiberi","C. lusitanica","E. calamita"),ordered = TRUE)

## ---------------------------------------------------------------------------------------- ##
## ggplot2
## ---------------------------------------------------------------------------------------- ##

## Colors
c1<-rgb(0.3,0.4,0.7,0.6) # LES
c2<-rgb(0.8,0.2,0.2,0.6) # HES
c3<-rgb(0.3,0.3,0.3,0.7) # Points



# Make boxplot
tiff(file=paste(outDirPlots,"/SPsum_Motorways_logScale_ggplot2.tif",sep=""),
     compression="lzw",res=300,height=2500,width=3500)

ggplot(DF,aes(x = grp3, y = SPsum, fill=grp4)) +
  ylab("SPsum") +
  xlab("Scenario (LES - Low-emissions, HES - High-emissions)") + 
  geom_boxplot(width=0.6,
               position = position_dodge(width=0.75),
               outlier.colour = c3, 
               outlier.size = 2) +
  scale_y_log10(breaks=c(50,100,500,1000,5000,10000,30000)) +
  facet_grid(.~grp2) + 
  scale_fill_manual(values = c(c1,c2), 
                    name="SPsum distribution",
                    breaks=as.factor(c("ALL","MOT")),
                    labels=c("Whole area", "Motorways")) + 
  theme(legend.title = element_text(size=16),
        legend.text = element_text(size=14),
        axis.text=element_text(size=16),
        axis.title=element_text(size=18),
        strip.text.x = element_text(size=14,face = "italic")) 

dev.off()







