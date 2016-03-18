# Author: Walter Xie
# Accessed on 18 Mar 2016
#
# https://github.com/walterxie/ComMA
# devtools::install_github("walterxie/ComMA")

library("ComMA")

setwd("~/WorkSpace/benchmark")

# For Mac OS time.txt has 4 lines for each xml, no newlines, which looks like
# generated/_GTRGI_1_1044.xml
# real	0m20.108s
# user	0m23.898s
# sys	0m1.727s
# generated/_GTRGI_2_1044.xml
# real	0m13.392s
# user	0m17.634s
# sys	0m0.334s
# file <- file.path(test, "time.txt")
getTimeDFMac <- function(file) {
	linn <- readFileLineByLine(file)
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
	
	return(time.df)
}

# generated/_GTRGI_1_1044.xml
#  20.11 real         23.90 user         1.72 sys
# generated/_GTRGI_2_1044.xml
#  13.39 real         17.63 user         0.33 sys
getTimeDFUnix <- function(file) {
	linn <- readFileLineByLine(file)
	linn <- gsub("\\s", "", linn)
	length(linn)

	time.m <- matrix(linn, ncol=2, byrow=TRUE)
	time.m[,1] <- gsub("generated/_", "", time.m[,1], ignore.case = T)
	time.m[,1] <- gsub(".xml", "", time.m[,1], ignore.case = T)
	time.m[,1] <- gsub(".nex", "", time.m[,1], ignore.case = T)

	time.df <- as.data.frame(time.m[,1:2], stringsAsFactors = FALSE)
	colnames(time.df) <- c("xml", "time")
	time.df$model <- sapply(strsplit(time.df$xml, "_"), "[[", 1)
	time.df$version <- sapply(strsplit(time.df$xml, "_"), "[[", 2)
	time.df$version <- gsub("1", "1.8.3", time.df$version, ignore.case = T)
	time.df$version <- gsub("2", "2.4.0", time.df$version, ignore.case = T)
	time.df$test <- sapply(strsplit(time.df$xml, "_"), "[[", 3)
    time.df$seconds <- sapply(strsplit(time.df$time, "real"), "[[", 1)
	
	return(time.df)
}


# time.df
# time.df[1:2,]
#           xml real.time model version test m      s seconds
#1 GTRGI_1_1044  0:20.108 GTRGI   1.8.3 1044 0 20.108  20.108
#2 GTRGI_2_1044  0:13.392 GTRGI   2.4.0 1044 0 13.392  13.392
reportTime <- function(time.df, test="1 Thread") {
    shared.cols <- c("xml","model","version","test","seconds")
    
    # print table
	#print(time.df[,shared.cols], row.names = FALSE)
	printXTable(time.df[,shared.cols], caption = paste("Time report of ", test), 
			  label = paste("tab:", test, sep = ":"), file=NULL)

    # bar chart 
	gtr.gi <- time.df[time.df$model=="GTRGI" & !grepl("benchmark", time.df$test, ignore.case=TRUE),]
	p1 <- ggBarChart(gtr.gi, x.id="test", y.id="seconds", fill.id="version", title="GTRGI")		   
	#print(p1)

	gtr.g <- time.df[time.df$model=="GTRG" & !grepl("benchmark", time.df$test, ignore.case=TRUE),]
	p2 <- ggBarChart(gtr.g, x.id="test", y.id="seconds", fill.id="version", title="GTRG")

	gtr.i <- time.df[time.df$model=="GTRI" & !grepl("benchmark", time.df$test, ignore.case=TRUE),]
	p3 <- ggBarChart(gtr.i, x.id="test", y.id="seconds", fill.id="version", title="GTRI")

	gtr <- time.df[time.df$model=="GTR" & !grepl("benchmark", time.df$test, ignore.case=TRUE),]
	p4 <- ggBarChart(gtr, x.id="test", y.id="seconds", fill.id="version", title="GTR")

	benchmark <- time.df[grepl("benchmark", time.df$test, ignore.case=TRUE),]
	benchmark$test <- paste(benchmark$model, benchmark$test, sep="_")	
	benchmark$test <- gsub("benchmark", "bk", benchmark$test, ignore.case = T)
	p5 <- ggBarChart(benchmark, x.id="test", y.id="seconds", fill.id="version", title="Benchmarks")

	g.table <- grid_arrange_shared_legend(p1, p2, p3, p4, p5)

	pdfGtable(g.table, fig.path=paste0(tolower(gsub(" ", "-", test)),".pdf"), width=8, height=12)
	
	# percentage bar chart
	time.df1 <- time.df[time.df$version=="1.8.3",]
	time.df2 <- time.df[time.df$version=="2.4.0",]

	time.df.merge <- merge(time.df1[,shared.cols], time.df2[,shared.cols], by=c("model","test"))
	time.df.merge$performance <- time.df.merge$seconds.y / time.df.merge$seconds.x 

	p <- ggBarChart(time.df.merge, x.id="test", y.id="performance", fill.id="model", y.scale="per", title=paste0("BEAST 2 Time Over BEAST 1 (", test, ")"))
	
	pdfGgplot(p, fig.path=paste0(tolower(gsub(" ", "-", test)),"-perf.pdf"), width=8, height=8) 

}

time.df <- getTimeDFMac(file.path("1 Thread", "time.txt"))
reportTime(time.df, "singleThread")

time.df <- getTimeDFMac(file.path("2 Threads", "time.txt"))
reportTime(time.df, "doubleThread")

time.df <- getTimeDFMac(file.path("4 Threads", "time.txt"))
reportTime(time.df, "fourThread")

time.df <- getTimeDFMac(file.path("GPU", "time.txt"))
reportTime(time.df, "GPU")
