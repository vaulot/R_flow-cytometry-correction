## Correction for flow cytometry histograms when part of the population is in noise

This has been published in the following paper :

Gérikas Ribeiro C, Marie D, Lopes dos Santos A, Pereira Brandini F, Vaulot D. (2016). Estimating microbial populations by flow cytometry: Comparison between instruments. Limnol Oceanogr Methods in press. doi:10.1002/lom3.10135.

The code describes how to implement an R routine to correct the abundance of picoplanktonic populations based on their red fluorescence distribution. All libraries used here are freely available from R repositories. The input file used in this example is named  Pro_C6.txt (See input file example). This file has been created by exporting FL3 (chlorophyll) histogram from the Flowing Software (http://www.flowingsoftware.com) combining different samples into a single file. The first column contains the channel number and each following column corresponds to a different sample with rows corresponding to cell counts in each channel. Such a file could be created with any flow cytometry software.  After running the cyto_plot function, a pdf output file is created named "Pro_C6.txt 1.0 .pdf" which contains all histograms from the input file and the file statistics (sample, uncorrected and corrected total cell abundance) are available as a data frame in the R session (see example at bottom of this file)


### Example of use of cyto_plot function (run first the R code below to define the necessary functions)<p> 
stats_Pro_C6<-cyto_plot("Pro_C6.txt", decades_C6, channel_min_C6, xmin_C6, xmax_C6)

### Example of statistics output<p> 

 id | sample                  	| cell_tot	| cell_tot_correc 
 --- | --- | --- | ---
1 | sample135_C6_PRO_5m     	| 134  	| cells in noise 
2 | sample136_C6_PRO_50m    	| 111  	| cells in noise 
3 | sample137_C6_PRO_110m   	| 13072	| 20240 
4 | sample138_C6_PRO_130m   	| 3598   	| no correction 
5 | sample139_C6_PRO_170m   	| 2211   	| no correction 
