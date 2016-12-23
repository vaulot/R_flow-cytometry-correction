# Install libraries
library("ggplot2")
library("reshape2")
library("plyr")
library("scales")
require(grid)

# Set the working directory where the files are located 
setwd ("C:/My Documents/cytometry data/")  

# Define basic parameters for the Canto and C6
decades_Canto = 5
decades_C6 = 7
channel_min_Canto = 100
channel_min_C6 = 214
xmin_Canto = 10
xmin_C6 = 1000
xmax_Canto = 10000
xmax_C6 = 100000
channel_max = 500
point <- format_format(big.mark = "", decimal.mark = ".", scientific = TRUE)
# ---------------------------------------------------------
# cell_correct(channel, cell_number, cell_smooth)
# Arguments
# 	channel : vector containing the channels (from 1 to 500 in the present case)
#	cell_number : vector containing cell abundance in each channel
#	cell_smooth : vector containing smoothed cell abundance in each channel
# Description
# This function determines in which case we are ("no correction", "cells in noise" or "correction")and return the corrected cell abundance in the latter case. 

cell_correct<-function(channel, cell_number, cell_smooth)
{ df<-data.frame(channel, cell_number, cell_smooth)	# create a data frame
i_min<-which.min(channel)				# determine the minimum channel
i_max<-which.max(channel)				# determine the maximum channel
i_cell_max<-which.max(cell_smooth)			# determine in which channel is the histogram mode

# “no correction” : cell abundance in the first channel is 5 times lower than abundance at the maximum of the histogram
if (cell_smooth[i_cell_max]>5*cell_smooth[i_min])	{cell_correct<-"no correction"}
# “cells in noise” : maximum of cell abundance is in the first channel 
  else {if (i_cell_max==i_min)
	{cell_correct<-"cells in noise"}
# “correction” : all the other cases, we then apply a correction by computing the total cell abundance as twice the number of cells in the channels right of the histogram maximum
  else
	{cell_correct<-2*sum(cell_number[i_cell_max:i_max])}
	}
  return (cell_correct)
}

# ---------------------------------------------------------
#cyto_plot(file_name,decades,channel_min,xmin,xmax)
# Arguments
#	file_name : name of input file containing the different samples (see File S1)
#	decades : number of logarithmic decades of the flow cytometer (e.g. 7 for C6)
#	channel_min : threshold channel for the histogram (depends on fcm acquisition settings)
#	xmin : linear value corresponding to the threshold channel 
#	xmax : linear value corresponding to the maximum channel
# Description
# This function plots a set of histograms for the input samples,saves the graphics as a pdf file and compute the total cell abundance indicating whether a corrections is needed or not.  It returns a dataframe containing three columns : sample, cell_tot, cell_tot_correc (see top of this file for an example)

cyto_plot<-function(file_name,decades,channel_min,xmin,xmax)
{ 	channel_max = 500 # this the number of channels provided as output of the Flowing Software
	histo<- read.delim(file_name)
	histo<- histo[histo$channel>=channel_min,]
	histo_melt<-  melt(histo, id.vars=c("channel"),variable.name = "sample", value.name = "cell_number")


# smooth histogram using default R smoothing function
	histo_melt<- ddply(histo_melt,c("sample"), transform, cell_smooth=as.vector(smooth(cell_number)))
# normalize histogram so that maximum abundance is equal to 1
	histo_melt<- ddply(histo_melt,c("sample"), transform, cell_norm=cell_smooth/max(cell_smooth))
# transform log channel to linear scale for plotting
	if (decades==5)  
		{histo_melt<- ddply(histo_melt,c("sample"), transform, fluo=(10^5)^(channel/channel_max))}
	else
		{histo_melt<- ddply(histo_melt,c("sample"), transform, fluo=(10^7)^(channel/channel_max))}
# plots histograms using 5 columns
	histo_plot<-ggplot(histo_melt, aes(fluo,cell_norm)) + geom_line() + theme_bw () + facet_wrap(~ sample, nrow=21, ncol=5) + xlab("Chlorophyll")+ylab("Relative cell number") + scale_x_log10(limits=c(xmin,xmax), labels=point) 
# save plots as pdf
ggsave(plot=histo_plot, filename=paste(file_name," 1.0 .pdf",sep=""),width = 15, height = 4, scale=2, units="cm")	
# compute uncorrected and corrected total cell number calling the cell_correct function defined above
	stats<-ddply(histo_melt,c("sample"),summarise, cell_tot=sum(cell_number),cell_tot_correc=cell_correct(channel,cell_number,cell_smooth))
	print(paste("# of decades:",decades,"minimum channel : ",channel_min, "xmin : ",	xmin, " xmax : ",	xmax))
	print (paste("File : ",file_name))
	stats
	return (stats)
}
