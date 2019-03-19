

require(raster)
require(ggplot2)

# Boxplots by species/scenario per connectivity metric

fileList<-list.files("D:/MyDocs/Projects/Colab_ECivantos/data/ConnectMetrics",pattern=".tif$",full.names=TRUE,recursive=TRUE)
filesBySp<-list()


#connMetrics<-c("FPI_distThresh_25000","MFD_k_1","MFD_k_5")
#connMetrics<-c("MFD_k_5","MFD_k_1")
connMetrics<-c("MFD_k_5")

#connMetricsNames<-c("Functional Proximity Index (d=25000)","Functional Distance (k=1)","Mean Functional Distance (k=5)")
connMetricsNames<-c("Mean Functional Distance (k=5)","Functional Distance (k=1)")

names(connMetricsNames)<-connMetrics
spCodes<-c("ANGFR","LACSH","CHALU","BUCAL")
spNames<-c("A. fragilis","L. schreiberi","C. lusitanica","E. calamita")
names(spNames)<-spCodes
rcpCodes<-c("RCP26","RCP85")
rcpCodeNames<-c("LES","HES")
names(rcpCodeNames)<-rcpCodes



for(sp in spCodes){
	
	for(rcp in rcpCodes){
		tmp<-fileList[grep(sp,fileList)]
		
		filesBySp[[sp]][[rcpCodes[1]]]<-sort(tmp[grep(rcpCodes[1],tmp)])
		filesBySp[[sp]][[rcpCodes[2]]]<-sort(tmp[grep(rcpCodes[2],tmp)])
		
	}
}


tmpData<-list()


outDirPlots<-"D:/MyDocs/temp/colab_EC"

#cols<-c(colors()[251],colors()[226])
c2<-rgb(0.1,0.1,0.1,0.3)
c1<-rgb(1,1,1)
#c1<-rgb(255/255,222/255,38/255)
#c2<-rgb(206/255,130/255,0/255)
cols<-c(c1,c2)

at.x<-c(0.5,1, 1.75,2.25, 3,3.5, 4.25,4.75)

for(cm in connMetrics){
	
	
	# Read raster data into list structure
	# -----------------------	--------------------------------------------------------------------------
	
	for(sp in spCodes){
	
		for(rcp in rcpCodes){

			fileToRead<-filesBySp[[sp]][[rcp]]
			fileToRead<-fileToRead[grep(cm,fileToRead)]
			cat("Reading file:",fileToRead,".............")
			
			tmpData[[cm]][[paste(spNames[sp],rcpCodeNames[rcp],sep=" | ")]]<-na.omit(values(raster(fileToRead)))
			
			cat("done.\n\n")
		}
	}
	
	# Make boxplots #
	# -------------------------------------------------------------------------------------------------
	
	tiff(file=paste(outDirPlots,"/",cm,"_logScaleNotch_OutTrue_NoBox.tif",sep=""),compression="lzw",res=600,height=6000,width=6600)
	#par(oma=c(2,1,2,2),mar=c(4,4,2,2),mai=c(1,1,1,1))
  par(mar=c(10,8,1,1))
	
  boxplot(tmpData[[cm]],range=0,outline=TRUE,col=cols,cex.lab=1.5,cex.axis=1.5,boxwex=0.4,las=2,log="y",
	        main="",#main=connMetricsNames[cm],
	        cex=2,notch=TRUE,ylab="",at=at.x,
	        ylim=c(20,40000),xlim=c(0.25,max(at.x)+0.25),names=rep("",8))
	
	
	legend("topright",legend=c("Low-emissions scenario (LES)","High-emissions scenario (HES)"),fill=cols,cex=1.3)
	

	
	mtext("Mean Functional Distance (k=5)",2,at=1000,las=3,cex=1.7,line=5)
	mtext(spNames[1],1,at=mean(at.x[1:2]),las=2,cex=1.7,line=1,font=3)
	mtext(spNames[2],1,at=mean(at.x[3:4]),las=2,cex=1.7,line=1,font=3)
	mtext(spNames[3],1,at=mean(at.x[5:6]),las=2,cex=1.7,line=1,font=3)
	mtext(spNames[4],1,at=mean(at.x[7:8]),las=2,cex=1.7,line=1,font=3)
	
	dev.off()
	
}






## ------------------------------------------------------------------------------------------------- ##
## Make boxplot using ggplot2 graphics
## ------------------------------------------------------------------------------------------------- ##


## Colors
c1<-rgb(0.3,0.4,0.7,0.6) # LES
c2<-rgb(0.8,0.2,0.2,0.6) # HES
c3<-rgb(0.3,0.3,0.3,0.7) # Points
  
## Reshape data from list to data frame
ltS<-sapply(tmpData[[cm]],length)
repS<-c(ltS1<-sum(ltS[1:2]),
        ltS2<-sum(ltS[3:4]),
        ltS3<-sum(ltS[5:6]),
        ltS4<-sum(ltS[7:8]))

d <- data.frame(x = unlist(tmpData[[cm]]), 
                grp1 = as.factor(rep(1:4, times=repS)),
                grp2 = as.factor(rep(rep(1:2,4), times=ltS))) 
d<-cbind(d,grp3=paste(d$grp1,d$grp2,sep=" | "))


# Make boxplot
tiff(file=paste(outDirPlots,"/",cm,"_logScale_ggplot2.tif",sep=""),compression="lzw",res=300,height=2500,width=3500)
ggplot(d,aes(x = grp1, y = x, fill=grp2)) +
  ylab("Mean Functional Distance (k=5)") +
  xlab("Species") + 
  geom_boxplot(width=0.6,
               position = position_dodge(width=0.6),
               outlier.colour = c3, 
               outlier.size = 2) + 
  scale_fill_manual(values = c(c1,c2), 
                    name="Scenario",
                    breaks=1:2,
                    labels=c("Low-emissions (LES)","High-emissions (HES)")) +
  scale_y_log10(breaks=c(50,100,500,1000,5000,10000,30000)) + 
  scale_x_discrete(breaks=1:4,
                   labels=c("A. fragilis", "L. schreiberi","C. lusitanica", "E. calamita")) + 
  theme(legend.title = element_text(size=17),
        legend.text = element_text(size=15),
        axis.text=element_text(size=16),
        axis.text.x=element_text(face = "italic"),
        axis.title=element_text(size=18))
dev.off()







## ------------------------------------------------------------------------------------------------- ##
## Calculate some statistics
## ------------------------------------------------------------------------------------------------- ##



calcStats<-function(x) return(list(c(fivenum(x),mean(x),sd(x))))

statsList<-list()

for(cm in connMetrics){
	
	x<-unlist(lapply(tmpData[[cm]],calcStats))
	statsList[[cm]]<-matrix(x,nrow=8,ncol=7,byrow=TRUE,dimnames=list(names(tmpData[[1]]),c("MIN","1Q","2Q","3Q","Max","MN","SD")))
	

	write.csv(statsList[[cm]],paste(outDirPlots,"/statsConnectAnalysis_",cm,"_v1.csv",sep=""))
	
}



