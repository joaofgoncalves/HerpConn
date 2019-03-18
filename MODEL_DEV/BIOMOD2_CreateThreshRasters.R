


# ---------------------------------------------------------------------------------------------- #
# Creates a thresholded/binary version of ensembled predictions (in GeoTIFF format) using the 
# ROC/AUC cutoff value for each species, projection name and ensemble type (mean, median and 
# ROC/AUC weighted-mean)
# ---------------------------------------------------------------------------------------------- #

rm(list=ls())

require(biomod2)
require(raster)

# !!! Change the working directory according to your system
setwd("D:/MyDocs/temp/tmp_ECivantos/data")

# Projection names and species codes used
projNames<-c("Current","RCP26_2050","RCP85_2050")
#spCodes<-c("BUCAL","LACLE","PODHP","SALAM","CHALU","LACSH")
spCodes<-c("ANGFR")



for(sp in spCodes){
	
	# Load the ensemble object for each species
	load(paste(sp,"_BIOMOD2_ensembleObj_v2_ROC.RData",sep=""))
	
	for(i in 1:length(ensembleObj)){
		
		# Get model evaluations for each model in order to get the 
		modEns<-get_evaluations(ensembleObj)
		
		cut1<-modEns[[1]][2] # Cutoff for mean ensemble
		cut2<-modEns[[2]][2] # Cutoff for median ensemble
		cut3<-modEns[[3]][2] # Cutoff for weighted-mean ensemble
		
		for(projName in projNames){
			
			cat("Species:",sp,"| Scnenario:",projName,".........\n-> Reading raster data...")
			
			
			if(projName == "Current"){
				
				rst.ens.avg<-raster(paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_avg.tif",sep=""))
				rst.ens.med<-raster(paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_med.tif",sep=""))
				rst.ens.wmn<-raster(paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_wmn.tif",sep=""))
				
			}else{
				
				rst.ens.avg<-raster(paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_avg_intDel2a.tif",sep=""))
				rst.ens.med<-raster(paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_med_intDel2a.tif",sep=""))
				rst.ens.wmn<-raster(paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_wmn_intDel2a.tif",sep=""))	
			}
			
			cat("done.\n-> Creating new rasters...")
			
			rst.ens.avg.thresh<-raster(rst.ens.avg)
			values(rst.ens.avg.thresh)<-as.integer(values(rst.ens.avg) >= cut1)
			writeRaster(rst.ens.avg.thresh,paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_avg_thresh.tif",sep=""))
		
			cat("AVG...")
			
			rst.ens.med.thresh<-raster(rst.ens.med)
			values(rst.ens.med.thresh)<-as.integer(values(rst.ens.med) >= cut2)
			writeRaster(rst.ens.med.thresh,paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_med_thresh.tif",sep=""))
			
			cat("MED...")
			
			rst.ens.wmn.thresh<-raster(rst.ens.wmn)
			values(rst.ens.wmn.thresh)<-as.integer(values(rst.ens.wmn) >= cut3)
			writeRaster(rst.ens.wmn.thresh,paste("./",sp,"/proj_",projName,"/proj_",projName,"_",sp,"_ensemble_wmn_thresh.tif",sep=""))
			
			cat("WMN... done.\n\n\n")
		}
	}
}





