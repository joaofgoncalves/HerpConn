

require(biomod2)

setwd("D:/MyDocs/temp/tmp_ECivantos")


spCodes<-c("BUCAL","CHALU","LACSH","ANGFR")


for(sp in spCodes){
	
	# ---------------------------------------------------------------------------------- #
	# Partial model evaluations 
	# ---------------------------------------------------------------------------------- #
	
	load(paste("D:\\MyDocs\\temp\\tmp_ECivantos\\data\\_MOD_OBJECTS\\",sp,"\\",sp,"_BIOMOD2_ModObject_v2.RData",sep=""))
	
	modEval<-get_evaluations(modObj)
	
	
	# ROC-AUC -------------------- #
	modEvalAUC<-modEval[3,1,,,]
	# TSS ------------------------ #
	modEvalTSS<-modEval[2,1,,,]
	
	nPA<-dim(modEvalAUC)[3]
	
	for(i in 1:nPA){
		
		if(i==1){
			tmp1<-apply(modEvalAUC[,,i],1,mean,na.rm=TRUE)
			tmp2<-apply(modEvalTSS[,,i],1,mean,na.rm=TRUE)
		}else{
			tmp1<-cbind(tmp1,apply(modEvalAUC[,,i],1,mean,na.rm=TRUE))
			tmp2<-cbind(tmp2,apply(modEvalTSS[,,i],1,mean,na.rm=TRUE))
		}
		
	}
	
	tmp1<-cbind(tmp1,apply(tmp1,1,mean))
	tmp2<-cbind(tmp2,apply(tmp2,1,mean))
	
	colnames(tmp1)<-c(paste("PA_set",1:nPA,sep="_"),"MN")
	colnames(tmp2)<-c(paste("PA_set",1:nPA,sep="_"),"MN")
	
	tmp1<-round(t(tmp1),2)
	tmp2<-round(t(tmp2),2)
	
	write.csv(tmp1,paste(sp,"AUC_By_PAset_Algo.csv",sep="_"))
	write.csv(tmp2,paste(sp,"TSS_By_PAset_Algo.csv",sep="_"))
	
	# ---------------------------------------------------------------------------------- #
	# Ensemble models evaluations
	# ---------------------------------------------------------------------------------- #
		
	load(paste("D:\\MyDocs\\temp\\tmp_ECivantos\\data\\_MOD_OBJECTS\\",sp,"\\",sp,"_BIOMOD2_ensembleObj_v3_AllEvalStats.RData",sep=""))
	
	modEval<-get_evaluations(ensembleObj)[[1]]
	
	write.csv(modEval,paste(sp,"AUC_Mean_EnsembleMod.csv",sep="_"))
	
	
}


