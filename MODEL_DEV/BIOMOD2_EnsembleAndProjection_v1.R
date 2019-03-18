

# ----------------------------------------------------------------------------------- #
# This script performs model ensembing, projection and forecasting
# ----------------------------------------------------------------------------------- #


rm(list=ls())

require(biomod2)
require(raster)

# Define the work directory for BIOMOD2
# !!! Change the working directory according to your system
# setwd("D:/MyDocs/Projects/Colab_ECivantos/data/_MOD_PREDS_v2")



# ----------------------------------------------------------------------------------- #
# Get the best modeling algorithms based on the median for all calibrated models
#
# Then, for each of the best algorithms extract the 2.5% top performing models based 
# on ROC/AUC. The selected models in the ensModels list object will then be used for 
# ensembling procedures
# ----------------------------------------------------------------------------------- #


# Species codes
#spCodes<-c("BUCAL","LACLE","PODHP","SALAM","CHALU","LACSH")
spCodes<-c("ANGFR","BUCAL","CHALU","LACSH")

# Modeling algorithms used
modAlgos<-c("GLM","GBM","GAM","CTA","FDA","RF","MAXENT")

# Nr of algorithms to retain
#nBest<-c(4,3,3,3)
#nBest<-rep(4,4)
#names(nBest)<-spCodes
nBest<-5


# List of best models retained
ensModels<-list()


## Extract the best modeling algorithms/runs
for(sp in spCodes){
	
	setwd(paste("D:/MyDocs/Projects/Colab_ECivantos/data/_MOD_OBJECTS",sp,sep="/"))
	
	# Load the biomod modeling object for each species
	load(paste(sp,"_BIOMOD2_ModObject_v2.RData",sep=""))
	
	modEvals<-get_evaluations(modObj)
	ensModels[[sp]]<-c()
	modEvalByAlgo<-c()
	
	# Select the 5 best modeling algorithms
	for(m in modAlgos)
		modEvalByAlgo<-c(modEvalByAlgo,median(modEvals[3,1,m,,],na.rm=TRUE))
	
	names(modEvalByAlgo)<-modAlgos	
	modEvalByAlgo<-sort(modEvalByAlgo,decreasing=TRUE)
		
	print(sp)
	print(modEvalByAlgo)
		
	# Best 5 modeling algorithms
	modAlgos1<-names(modEvalByAlgo)[1:nBest]
		
	#
	# Extract the best calibrated models for each of the 5 best modeling algorithms 
	# based on the 0.975 quantile
	for(m in modAlgos1){
		tmp<-modEvals[3,1,m,,]
		
		quant<-quantile(tmp,probs=0.975,na.rm=TRUE)
	
		for(i in 1:ncol(tmp)){
			for(j in 1:nrow(tmp)){
				
				# If the model performance is equal or above the 97.5% quantile then it's retained for ensembling
				if(!is.na(tmp[j,i]) & (tmp[j,i] >= quant))
					ensModels[[sp]]<-c(ensModels[[sp]],paste(sp,"_PA",i,"_RUN",j,"_",m,sep=""))
			}
		}
	}
}



# ----------------------------------------------------------------------------------- #
# Perform ensemble modeling
# ----------------------------------------------------------------------------------- #


#spCodes<-c("BUCAL","LACLE","PODHP","SALAM","CHALU","LACSH")
spCodes<-c("ANGFR","BUCAL","CHALU","LACSH")

setwd("I:/temp/colab_EC")	

for(sp in spCodes){

	
	
	# Load the modeling object
	load(paste("D:/MyDocs/Projects/Colab_ECivantos/data/_MOD_OBJECTS/",sp,"/",sp,"_BIOMOD2_ModObject_v2.RData",sep=""))
	
	# Perform ensembling based on the previously selected models (in the ensModels list object)
	# Uses mean, median and weighted-mean ensemble types
	#
	ensembleObj <- BIOMOD_EnsembleModeling( modeling.output = modObj,
										chosen.models = ensModels[[sp]],
										em.by = "all",
										eval.metric = c("ROC","TSS"),
										eval.metric.quality.threshold = NULL, # Discard models below 0.5
										prob.mean = TRUE,
										prob.cv = FALSE,
										prob.ci = FALSE,
										prob.ci.alpha = 0.05,
										prob.median = TRUE,
										committee.averaging = FALSE,
										prob.mean.weight = TRUE,
										prob.mean.weight.decay = "proportional")

	# Save the ensemble object						
	save(ensembleObj,file=paste(sp,"_BIOMOD2_ensembleObj_v3_AllEvalStats.RData",sep=""))
								
								
	# Calculate evaluation scores for the ensemble models
	print(get_evaluations(ensembleObj))	
}



# ----------------------------------------------------------------------------------- #
# Reads rasters contained in each input scenario folder and produces 
# new raster stacks used for projection and ensemble forecasting
# 
# Forecast results based on current conditions and cc-scenarios for 2050 (RCP 2.6 and 8.5)
# ----------------------------------------------------------------------------------- #


# !!! Change the path to the raster directories according to your system
# This function lists only GeoTIFF files in each folder
rstDataFileList<-list(
	current=list.files("D:/MyDocs/Projects/Colab_ECivantos/data/SpatialData/_Present",pattern=".tif$",full=TRUE),
	rcp26 = list.files("D:/MyDocs/Projects/Colab_ECivantos/data/SpatialData/2050_B2_RCP26",pattern=".tif$",full=TRUE),
	rcp85 = list.files("D:/MyDocs/Projects/Colab_ECivantos/data/SpatialData/2050_A1_RCP85",pattern=".tif$",full=TRUE)
)

# Build a raster stack using the selected variables
selVars<-c(2,4,5,6,14,20,23,29,32,24)

# Indicate which rasters are factor/categorical variables
selVarFactor<-c(rep(FALSE,length(selVars)-1),TRUE)

##

j<-0
rstList<-list()
rstStacks<-list()

for(rstDataFiles in rstDataFileList){
	j<-j+1
	z<-0
	for(i in selVars){
		z<-z+1
		
		if(selVarFactor[z]){
			rstList[[z]]<-as.factor(raster(rstDataFiles[i]))
		}
		else{
			# A workaround to convert 8-bit rasters into floats and avoid using them as factors
			rstList[[z]]<-raster(rstDataFiles[i]) 
			if(is.factor(rstList[[z]]))
				rstList[[z]]<-rstList[[z]]*(1+1E-38)
		}
	}
	
	# Create the raster stack for each projection type
	rstStacks[[j]]<-stack(rstList)
}




## Reclassify values
## 5/8 (Abandoned lands to semi-natural vegetation)

# 2050 / RCP 2.6
#
rstData<-getValues(rstStacks[[2]])

ind<-rstData[,"CLC_LULC"]==5
ind[is.na(ind)]<-FALSE
rstData[ind,"CLC_LULC"]<-3

ind<-rstData[,"CLC_LULC"]==8
ind[is.na(ind)]<-FALSE
rstData[ind,"CLC_LULC"]<-3

rstStacks[[2]]<-setValues(rstStacks[[2]],rstData[,"CLC_LULC"],layer=10)

# 2050 / RCP 8.5
#
rstData<-getValues(rstStacks[[3]])

ind<-rstData[,"CLC_LULC"]==5
ind[is.na(ind)]<-FALSE
rstData[ind,"CLC_LULC"]<-3

ind<-rstData[,"CLC_LULC"]==8
ind[is.na(ind)]<-FALSE
rstData[ind,"CLC_LULC"]<-3

rstStacks[[3]]<-setValues(rstStacks[[3]],rstData[,"CLC_LULC"],layer=10)


# ----------------------------------------------------------------------------------- #
# Perform projection and ensemble forecasting for each scenario
# ----------------------------------------------------------------------------------- #

memory.limit(6000)

## Set the working directory to the base dir (with a folder per species)
setwd("I:/temp/colab_EC")


# Species codes and distances
#spCodes<-c("BUCAL","LACLE","PODHP","SALAM","CHALU","LACSH")
spCodes<-c("LACSH")

# Projection names
projNames<-c("Current","RCP26_2050","RCP85_2050")


for(sp in spCodes){

	# Load the modeling object (modObject) and the ensemble object (ensembleObj)
	# from the target species folders 
	load(paste(getwd(),"/",sp,"/",sp,"_BIOMOD2_ModObject_v2.RData",sep=""))
	load(paste(getwd(),"/",sp,"/",sp,"_BIOMOD2_ensembleObj_v2_ROC.RData",sep=""))
	
	
	for(i in 1:length(rstStacks)){
	
		cat("Processing species:",sp,"| Scenario:",projNames[i],".......\n\n")
		
		# Perform projection for each scenario using models kept by the ensembling
		#
		projectionObj <- BIOMOD_Projection(	modeling.output = modObj,
											new.env = rstStacks[[i]],
											proj.name = projNames[i],
											selected.models = get_kept_models(ensembleObj,model=1),
											compress = TRUE,
											build.clamping.mask = FALSE)
										
		# Save the projection object
		save(projectionObj,file=paste(sp,"_BIOMOD2_projectionObj_",projNames[i],"_v2.RData",sep=""))
				
		# Perform ensemble forecasting
		BIOMOD_EnsembleForecasting( projection.output = projectionObj,
									EM.output = ensembleObj)
		
		# Export the ensemble projections into GeoTIFF format
		# Read raster data
		rstEnsProj.avg<-raster(paste(getwd(),"/",sp,"/proj_",projNames[i],"/proj_",projNames[i],"_",sp,"_ensemble.grd",sep=""),band=1)
		rstEnsProj.med<-raster(paste(getwd(),"/",sp,"/proj_",projNames[i],"/proj_",projNames[i],"_",sp,"_ensemble.grd",sep=""),band=2)
		rstEnsProj.wmn<-raster(paste(getwd(),"/",sp,"/proj_",projNames[i],"/proj_",projNames[i],"_",sp,"_ensemble.grd",sep=""),band=3)
		
		# Write new raster data into GeoTIFF
		writeRaster(rstEnsProj.avg,filename=paste(getwd(),"/",sp,"/proj_",projNames[i],"/proj_",projNames[i],"_",sp,"_ensemble_avg.tif",sep=""))
		writeRaster(rstEnsProj.med,filename=paste(getwd(),"/",sp,"/proj_",projNames[i],"/proj_",projNames[i],"_",sp,"_ensemble_med.tif",sep=""))
		writeRaster(rstEnsProj.wmn,filename=paste(getwd(),"/",sp,"/proj_",projNames[i],"/proj_",projNames[i],"_",sp,"_ensemble_wmn.tif",sep=""))
		
		cat("\n\n")

	}
}
		
					
											
											