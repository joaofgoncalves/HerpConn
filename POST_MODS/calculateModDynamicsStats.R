

require(raster)


fileNames<-list.files("D:/MyDocs/Projects/Colab_ECivantos/data/HabitatDynamics",pattern=".tif$")
filePaths<-list.files("D:/MyDocs/Projects/Colab_ECivantos/data/HabitatDynamics",pattern=".tif$",full.names=TRUE)

i<-0
rNames<-c()

for(f in filePaths){
	i<-i+1
	
	rst<-raster(f)
	rstValues<-na.omit(values(rst))

	tmp<-unlist(strsplit(fileNames[i],"_"))	
	spCode<-tmp[1]
	projName<-gsub(".tif","",tmp[length(tmp)])
	rNames<-c(rNames,paste(spCode,projName,sep="_"))
	
	if(i==1){
		res<-as.numeric(table(rstValues))
	}else{
		
		res<-rbind(res,as.numeric(table(rstValues)))
	}
	print(rNames[i])
	print(table(rstValues))
	
}


colnames(res)<-c("Unsuitable","New","Lost","Kept")
rownames(res)<-rNames

write.csv(res,file="D:/MyDocs/temp/colab_EC/habSuitabilityDynamics.csv")



