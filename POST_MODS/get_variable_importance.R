


library(biomod2)



load("D:/MyDocs/Projects/Colab_ECivantos/data/_MOD_OBJECTS/ANGFR/ANGFR_BIOMOD2_AllObjects_v2.RData")
vnames<-modObj@expl.var.names


spCodes<-c("ANGFR","BUCAL","CHALU","LACSH")

varImpBySp<-matrix(nrow=length(vnames),ncol=length(spCodes),dimnames=list(vnames,spCodes))


for(sp in spCodes){
	

	load(paste("D:\\MyDocs\\Projects\\Colab_ECivantos\\data\\_MOD_OBJECTS\\",sp,"\\",sp,"_BIOMOD2_ModObject_v2.RData",sep=""))
	
	vimpArray<-get_variables_importance(modObj)

	tmpVIMP<-apply(vimpArray,MARGIN=c(1,2),FUN=mean,na.rm=TRUE)
	
	varimp<-apply(tmpVIMP,1,mean)

	tmpVIMP<-cbind(tmpVIMP,MN_VIMP_ALL_MOD=varimp)
	
	write.csv(tmpVIMP,file=paste("D:/MyDocs/Projects/Colab_ECivantos/data/",sp,"_varImportance.csv",sep=""))
	
	varImpBySp[names(varimp),sp]<-varimp



}



vimpRank<-apply(varImpBySp,2,function(x) rank(-x))


write.csv(varImpBySp,file="D:/MyDocs/Projects/Colab_ECivantos/data/varImportanceMeanBySpecies.csv")
write.csv(vimpRank,file="D:/MyDocs/Projects/Colab_ECivantos/data/varImportanceMeanRankBySpecies.csv")



