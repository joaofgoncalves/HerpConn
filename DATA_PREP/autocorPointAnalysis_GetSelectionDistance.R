

# --------------------------------------------------------------------------------------------------------- #
# This script uses a point selection routine to determine which separation distance best minimizes a 
# criterion of spatial autocorrelation based on the Clark-Evans test statistic
# --------------------------------------------------------------------------------------------------------- #




rm(list=ls())
memory.limit(6000)

require(spatstat)
require(sp)
#require(xlsx)


# !!! Change this setting according to your system
source("D:/MyDocs/Dev-Eclipse/Projects-Workspace/Misc/Colab_EC/autocorPointAnalysis.R")


# -------- #

df<-read.csv("D:/MyDocs/Projects/Colab_ECivantos/data/speciesData_PT1_UTM1km_ED50_29N_v2/Species_records_v3.csv")

#spCodes<-c("BUCAL","LACLE","PODHP","SALAM","CHALU","LACSH")
spCodes<-c("LACSH")

pVal<-0.001			# Not used in this version
ceStatTarget<-0.9 	# The Clark-Evans statistic value for which the distance is selected

distBySpecies<-vector(mode="numeric",length=length(spCodes))

i<-0

for(spCode in spCodes){
	
	df.sp<-df[df[,"SP_CODE"]==spCode,]
	
	cat("\n\n## ------------------------------------------------------------------------------------- ##\n")
	cat("--> Calculating distance for [",spCode,"]....\n\n")
	i<-i+1
	
	for(Dist in seq(2500,10000,250)){
		
		cat(Dist,"meters....")
		
		# Use point distance selection
		occ.sp<-occ.desaggragation(df.sp,colxy=5:6,colvar=NULL,min.dist=Dist,plot=FALSE)
		
		# Create ppp object
		occ.sp.ppp<-ppp(occ.sp[,1],occ.sp[,2],window=owin(c(min(occ.sp[,1])-500,max(occ.sp[,1])+500),
						c(min(occ.sp[,2])-500,max(occ.sp[,2])+500)))
		
		# Perform test on selected points
		ce.test<-clarkevans.test(occ.sp.ppp, alternative="clustered",correction="Donnelly")     
		
		if(round(ce.test$statistic,1) >= ceStatTarget #ce.test$p.value >= pVal
			){
			
			distBySpecies[i]<-Dist
			cat("R =",round(ce.test$statistic,3),"| p-value =",round(ce.test$p.value,5),".....Finished!\n\n\n")
			break
		}else{
			
			cat("R =",round(ce.test$statistic,3),"| p-value =",round(ce.test$p.value,5),".....\n")
			
		}
	}
}

nrow(df.sp[,5:6])
nrow(occ.sp[,1:2])

## Plot points

projInfo.ED50UTM29N<-CRS("+init=epsg:23029")
spPoints<-SpatialPoints(df.sp[,5:6], proj4string=projInfo.ED50UTM29N)
spPoints1<-SpatialPoints(occ.sp[,1:2], proj4string=projInfo.ED50UTM29N)

plot(spPoints,col="grey")
plot(spPoints1,col="red",add=TRUE)
box()


# --------------------------------------------------------------------------------------------------------- #
# Random test (uniformly distributed points)
# --------------------------------------------------------------------------------------------------------- #

#x<-runif(1000)
#y<-runif(1000)
#
#test.ppp<-ppp(x,y,window=owin(range(x),range(y)))
#
#clarkevans.test(test.ppp, alternative="clustered",correction="Donnelly")     




