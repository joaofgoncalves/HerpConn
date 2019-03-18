#
# BIOMOD 2

rm(list=ls())
memory.limit(6000)

require(biomod2)
require(raster)
require(xlsx)

# Load the point selection script
# !!! Change this setting according to your system
source("D:/MyDocs/Dev-Eclipse/Projects-Workspace/Misc/Colab_EC/autocorPointAnalysis.R")

# Define the work directory for BIOMOD2
# !!! Change this setting according to your system
setwd("D:/MyDocs/temp/tmp_ECivantos/data")


# --------------------------------------------------------------------------------------------------------------- #

# !!! Change the path to the raster directory according to your system
# This function lists only GeoTIFF files in the folder (uses current data)
rstDataFiles<-list.files("D:/MyDocs/temp/tmp_ECivantos/data/SpatialData/_Present",pattern=".tif$",full=TRUE)


# Build a raster stack using the selected variables:
# bio2
# bio4
# bio5
# bio6
# bio14
# catchArea_md
# catchArea_sd
# twi_md
# twi_sd
# CLC_LULC
selVars<-c(2,4,5,6,14,20,23,29,32,24)

# Indicate which rasters are factor/categorical variables
# Converts integer rasters into floats to avoid problems
selVarFactor<-c(rep(FALSE,length(selVars)-1),TRUE)

##
rstList<-list()
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

# Create a raster stack user present data
rstStack<-stack(rstList)
# Verify which variables are factors/categorical
cat("Which layers in the raster stack are factor variables?\n")
is.factor(rstStack)



# --------------------------------------------------------------------------------------------------------------- #
# Read data in the csv file to get XY data for presence records
# !!! Change this setting according to your system
spPresenceRecords<-read.csv("D:/MyDocs/temp/tmp_ECivantos/data/speciesData_PT1_UTM1km_ED50_29N_v2/Species_records_v3.csv", 
		stringsAsFactors=FALSE)

# Species codes and selection distances (based on autocorPointAnalysis_GetSelectionDistance.R script)
spCodes<-c("BUCAL","LACLE","PODHP","SALAM","CHALU","LACSH","ANGFR")
spDists<-c(7000,4250,3250,4000,3250,9250,3250) # these distances verify the condition Clark-Evans-statistic >= 0.9
names(spDists)<-spCodes

# Species name used to run modeling procedures
sp<-spCodes[7] # Change the index to change the species name

# XY Coordinates for the presence records for species sp 
xyData<-spPresenceRecords[spPresenceRecords[,"SP_CODE"]==sp,c("X_LONG","Y_LAT")]

# Selects a subset of the points to reduce spatial autocorrelation
xyDataSel<-occ.desaggragation(xyData,colxy=1:2,colvar=NULL,min.dist=spDists[sp],plot=FALSE)

# Create the spatial points object
projInfo.ED50UTM29N<-CRS("+init=epsg:23029")
spPoints<-SpatialPoints(xyDataSel, proj4string=projInfo.ED50UTM29N)



# ------------------------------------------------------------------------------------------------- #
# Create a BIOMOD2 data object with pseudo-absences generation
# ------------------------------------------------------------------------------------------------- #

biomodData<-BIOMOD_FormatingData(resp.var=spPoints,
								expl.var=rstStack,
								resp.name = sp,
								PA.nb.rep = 30,						# 30 different PA sets
								PA.nb.absences = nrow(xyDataSel), 	# Number of PAs equal to the nr of presences
								PA.strategy = 'random') 			# Random selection
						
# Create a SpatialPointsDataFrame with the selected presences
# Remove the discarded presences from background data
xyRaster<-raster(rstStack,layer=0)
xyRaster[1:length(xyRaster)]<-0						# Initialize the raster dataset
xyRaster[cellFromXY(xyRaster,xyData)]<--1			# Discarded presences
xyRaster[cellFromXY(xyRaster,xyDataSel)]<-1			# Selected presences


# Remove discarded presences from the pseudo-absences set					 
ind<-xyRaster@data@values[cellFromXY(xyRaster,biomodData@coord)]==-1
for(i in 1:ncol(biomodData@PA)){
	biomodData@PA[ind,i]<-FALSE
}	



# ------------------------------------------------------------------------------------------------- #
# Calibrate models
# Uses default model parametrization
# ------------------------------------------------------------------------------------------------- #

# Set some modeling options for RF, GAM and MAXENT
modOptions<-BIOMOD_ModelingOptions(
		RF=list(ntree=300,
				mtry=4,
				nodesize=2),
		GAM=list(k=4),
		MAXENT=list(path_to_maxent.jar="D:/MyDocs/Software/Maxent333k/maxent.jar", # Change this according to your system
				memory_allocated=2048)
)

# Run models
modObj<-BIOMOD_Modeling( biomodData,
                 models = c("GLM","GBM","GAM","CTA","FDA","RF","MAXENT"),
                 models.options = modOptions,
                 NbRunEval=10,  # Nr of evaluation rounds
                 DataSplit=80, # Splits data for test/train
                 Yweights=NULL,
                 Prevalence=NULL,
                 VarImport=10, # Calculates variable importance
                 models.eval.meth = c("KAPPA","TSS","ROC"),
                 SaveObj = TRUE,
                 rescal.all.models = TRUE,
                 do.full.models = FALSE)

# Save data and model object
save(modObj,file=paste(sp,"_BIOMOD2_ModObject_v2.RData",sep=""))
save(biomodData,file=paste(sp,"_BIOMOD2_biomodData_v2.RData",sep=""))
save.image(file=paste(sp,"_BIOMOD2_AllObjects_v2.RData",sep=""))


# Evaluation scores for individual models
get_evaluations(modObj)

modEvals<-get_evaluations(modObj)
fivenum(modEvals[3,1,"GLM",,])
fivenum(modEvals[3,1,"GBM",,])
fivenum(modEvals[3,1,"GAM",,])
fivenum(modEvals[3,1,"CTA",,])
fivenum(modEvals[3,1,"FDA",,])
fivenum(modEvals[3,1,"RF",,])
fivenum(modEvals[3,1,"MAXENT",,])

# Get variable importances
get_variables_importance(modObj)
		 








