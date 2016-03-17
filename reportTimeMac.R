# Author: Walter Xie
# Accessed on 18 Mar 2016
#
# https://github.com/walterxie/ComMA
# devtools::install_github("walterxie/ComMA")

library("ComMA")

setwd("~/WorkSpace/benchmark")

reportTime <- function(test) {
	linn <- readFileLineByLine(file.path(test, "time.txt"))
	length(linn)

	time.m <- matrix(linn, ncol=4, byrow=TRUE)
	time.m[,1] <- gsub("generated/_", "", time.m[,1], ignore.case = T)
	time.m[,1] <- gsub(".xml", "", time.m[,1], ignore.case = T)
	time.m[,1] <- gsub(".nex", "", time.m[,1], ignore.case = T)
	time.m[,2] <- gsub("real\t", "", time.m[,2], ignore.case = T)
	# convert 0m20.108s to 0:20.108
	time.m[,2] <- gsub("m", ":", time.m[,2], ignore.case = T)
	time.m[,2] <- gsub("s", "", time.m[,2], ignore.case = T)

	time.df <- as.data.frame(time.m[,1:2], stringsAsFactors = FALSE)
	colnames(time.df) <- c("xml", "real.time")
	time.df$model <- sapply(strsplit(time.df$xml, "_"), "[[", 1)
	time.df$version <- sapply(strsplit(time.df$xml, "_"), "[[", 2)
	time.df$version <- gsub("1", "1.8.3", time.df$version, ignore.case = T)
	time.df$version <- gsub("2", "2.4.0", time.df$version, ignore.case = T)
	time.df$test <- sapply(strsplit(time.df$xml, "_"), "[[", 3)
	time.df$m <- as.numeric(sapply(strsplit(time.df$real.time, ":"), "[[", 1))
	time.df$s <- as.numeric(sapply(strsplit(time.df$real.time, ":"), "[[", 2))
	time.df$seconds <- time.df$m * 60 + time.df$s

    # print table
	#print(time.df[,c("xml","model","version","test","seconds")], row.names = FALSE)
	printXTable(time.df[,c("xml","model","version","test","seconds")], caption = paste("Time report of ", test), 
			  label = paste("tab:", test, sep = ":"), file=NULL)

    # bar chart 
	gtr.gi <- time.df[time.df$model=="GTRGI",]
	p1 <- ggBarChart(gtr.gi, x.id="test", y.id="seconds", fill.id="version", title="GTRGI")		   
	#print(p1)

	gtr.g <- time.df[time.df$model=="GTRG",]
	p2 <- ggBarChart(gtr.g, x.id="test", y.id="seconds", fill.id="version", title="GTRG")

	gtr.i <- time.df[time.df$model=="GTRI",]
	p3 <- ggBarChart(gtr.i, x.id="test", y.id="seconds", fill.id="version", title="GTRI")

	gtr <- time.df[time.df$model=="GTR",]
	p4 <- ggBarChart(gtr, x.id="test", y.id="seconds", fill.id="version", title="GTR")

	g.table <- grid_arrange_shared_legend(p1, p2, p3, p4)

	pdfGtable(g.table, fig.path=paste0(tolower(test),".pdf"), width=8, height=9)
	
	# percentage bar chart
	time.df1 <- time.df[time.df$version=="1.8.3",]
	time.df2 <- time.df[time.df$version=="2.4.0",]

	time.df.merge <- merge(time.df1[,c("xml","model","version","test","seconds")], time.df2[,c("xml","model","version","test","seconds")], by=c("model","test"))
	time.df.merge$performance <- time.df.merge$seconds.y / time.df.merge$seconds.x 

	p <- ggBarChart(time.df.merge, x.id="test", y.id="performance", fill.id="model", y.scale="per", title="BEAST 2 Time Over BEAST 1")
	
	pdfGgplot(p, fig.path=paste0(tolower(test),"-perf.pdf"), width=8, height=8) 

}

reportTime("singleThread")

reportTime("doubleThread")

reportTime("fourThread")

reportTime("GPU")
