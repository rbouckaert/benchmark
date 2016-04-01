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
# 1 thread has 3 tests: BEAST 1 thread pool, no thread pool, BEAST2
# multi threads and GPU have 2 tests
getTimeDFMac <- function(file, test=2) {
	if (!(test == 2 || test == 3)) 
		stop("Invalid test number !")

	cat("Parsing time log", file, "from", getwd(), "\n")
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
	
	if (test == 3) {
		time.df$thread <- 1
		time.df[grepl("threads 0", time.df$xml, ignore.case=TRUE), "thread"] <- 0
		time.df$test <- gsub(" -threads 0", "", time.df$test, ignore.case = T)
	}
	
	return(time.df)
}

# For Windows time.txt has 2 lines for each xml, no newlines, which looks like
#generated/_GTRGI_1_1044.xml 
#command took 0:1:34.67 (94.67s total) 
#generated/_GTRGI_2_1044.xml 
#command took 0:1:24.70 (84.70s total) 
getTimeDFWindows <- function(file, test=2) {
	if (!(test == 2 || test == 3)) 
		stop("Invalid test number !")

	cat("Parsing time log", file, "from", getwd(), "\n")
	linn <- readFileLineByLine(file)
	length(linn)

	time.m <- matrix(trimStartEnd(linn), ncol=2, byrow=TRUE)
	time.m[,1] <- gsub("generated/_", "", time.m[,1], ignore.case = T)
	time.m[,1] <- gsub(".xml", "", time.m[,1], ignore.case = T)
	time.m[,1] <- gsub(".nex", "", time.m[,1], ignore.case = T)
	time.m[,2] <- gsub("^.*\\((.*)s total\\).*$", "\\1", time.m[,2])

	time.df <- as.data.frame(time.m[,1:2], stringsAsFactors = FALSE)
	colnames(time.df) <- c("xml", "seconds")
	time.df$model <- sapply(strsplit(time.df$xml, "_"), "[[", 1)
	time.df$version <- sapply(strsplit(time.df$xml, "_"), "[[", 2)
	time.df$version <- gsub("1", "1.8.3", time.df$version, ignore.case = T)
	time.df$version <- gsub("2", "2.4.0", time.df$version, ignore.case = T)
	time.df$test <- sapply(strsplit(time.df$xml, "_"), "[[", 3)
	time.df$seconds <- as.numeric(time.df$seconds)
	
	if (test == 3) {
		time.df$thread <- 1
		time.df[grepl("threads 0", time.df$xml, ignore.case=TRUE), "thread"] <- 0
		time.df$test <- gsub(" -threads 0", "", time.df$test, ignore.case = T)
	}
	
	return(time.df)
}

# time.df
#           xml real.time model version test m      s seconds
#1 GTRGI_1_1044  0:20.108 GTRGI   1.8.3 1044 0 20.108  20.108
#2 GTRGI_2_1044  0:13.392 GTRGI   2.4.0 1044 0 13.392  13.392
reportTime <- function(time.df, test=2, title="1 Thread", xtable.file=NULL, is.performance=FALSE) {
	if (!(test == 2 || test == 3)) 
		stop("Invalid test number !")

	shared.cols <- c("xml","model","version","test","seconds")
    if (test == 3) 
		shared.cols <- c(shared.cols,"thread")
    
    if (!is.performance) {
		# print table
		#print(time.df[,shared.cols], row.names = FALSE)
		printXTable(time.df[,shared.cols], caption = paste("Time report of ", tolower(title)), 
				  label = paste("tab:", tolower(title), sep = ":"), file=xtable.file)

		if (test == 3) 
			time.df[time.df$thread==0, "version"] <- paste0(time.df[time.df$thread==0, "version"], "(t", time.df[time.df$thread==0, "thread"], ")")
	
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
		pdfGtable(g.table, fig.path=paste0(gsub(" ", "-", tolower(title)),".pdf"), width=10, height=12)
	}
	
	if (test == 3) {	
		time.df1 <- time.df[time.df$version!="2.4.0" & time.df$thread==0,]		
		time.df1$version  <- gsub("(t0)", "", time.df1$version, ignore.case = T) # rm (t0)
		#time.df1 <- time.df[time.df$version=="1.8.3" & time.df$thread==1,]
		time.df2 <- time.df[time.df$version=="2.4.0",]
	} else {
		time.df1 <- time.df[time.df$version=="1.8.3",]
		time.df2 <- time.df[time.df$version=="2.4.0",]
	}
	time.df.merge <- merge(time.df1[,shared.cols], time.df2[,shared.cols], by=c("model","test"))
	time.df.merge$performance <- time.df.merge$seconds.x / time.df.merge$seconds.y 
	
	if (!is.performance) {
		p6 <- ggBoxWhiskersPlot(time.df.merge, x.id="model", y.id="performance", y.upper=2.5,
								add.mean=TRUE, title=paste0("Speed of BEAST2 over BEAST1 (", title, ")"))
		p6 <- ggLine(p6, linetype = 2, yintercept = 1)
		pdfGgplot(p6, fig.path=paste0(gsub(" ", "-", tolower(title)),"-perf.pdf"), width=6, height=6)
	} else {
		return(time.df.merge[,c("model","test","performance")])	
	}
}

######## report pipeline of Mac #######
report.file <- file.path(getwd(), "report.tex")

cat("\\documentclass{article}\n\n", file=report.file, append=FALSE)
# add packages here
cat("\\usepackage[utf8]{inputenc}","\\usepackage{graphicx}","\\usepackage{caption}","\n", file=report.file, append=TRUE, sep = "\n")
cat("\\title{GTR BEAST 1 vd 2}\n\n", file=report.file, append=TRUE)
cat("\\date{\\today}","\\begin{document}", "\\maketitle", file=report.file, append=TRUE, sep = "\n\n")

test=3
time.df <- getTimeDFMac(file.path("singleThread", "time.txt"), test)
reportTime(time.df, title="1 Thread", test, xtable.file=report.file)

test=2
time.df <- getTimeDFMac(file.path("doubleThread", "time.txt"), test)
reportTime(time.df, title="2 Threads", test, xtable.file=report.file)

time.df <- getTimeDFMac(file.path("fourThread", "time.txt"), test)
reportTime(time.df, title="4 Threads", test, xtable.file=report.file)

time.df <- getTimeDFMac(file.path("GPU", "time.txt"), test)
reportTime(time.df, title="GPU", test, xtable.file=report.file)

cat("\n\n\\end{document}", file=report.file, append=TRUE, sep = "\n")

# replace all _
system(paste("sed -i.bak 's/\\_/\\\\_/g;' ", report.file))

Sys.setenv(PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/texbin")
system(paste("pdflatex", report.file)) 

cat(paste("\n\nComplete report : ", report.file))

######## pipeline to get summary box plot of 3 OS #######
# create subfolder Linux and Windows under the working folder containing Mac result. 
for (title in c("1 Thread", "2 Threads", "4 Threads")) {
	test=2
	if (title=="2 Threads") {
		time.log=file.path("doubleThread", "time.txt")
	} else if (title=="4 Threads") {
		time.log=file.path("fourThread", "time.txt")
	} else { 
		test=3
		time.log=file.path("singleThread", "time.txt")
	}
	
	# Mac
	setwd("~/WorkSpace/benchmark")
	time.df <- getTimeDFMac(time.log, test)
	perf.df.mac <- reportTime(time.df, test, is.performance=TRUE)
	perf.df.mac$OS <- "Mac"

	# Linux
	setwd("~/WorkSpace/benchmark/Linux")
	time.df <- getTimeDFMac(time.log, test)
	perf.df.lin <- reportTime(time.df, test, is.performance=TRUE)
	perf.df.lin$OS <- "Linux"

	# Windows
	setwd("~/WorkSpace/benchmark/Windows")
	time.df <- getTimeDFWindows(time.log, test)
	perf.df.win <- reportTime(time.df, test, is.performance=TRUE)
	perf.df.win$OS <- "Windows"

    perf.df <- NULL
	perf.df <- rbind(perf.df.mac, perf.df.lin, perf.df.win)

	setwd("~/WorkSpace/benchmark")
	p <- ggBoxWhiskersPlot(perf.df, x.id="model", y.id="performance", fill.id="OS", y.upper=2.1,
						title=paste0("Speed of BEAST2 over BEAST1 (", title, ")"))	
	p <- ggLine(p, linetype = 2, yintercept = 1)
	p <- ggAddNumbers(p, fun.y.lab=mean)
	pdfGgplot(p, fig.path=paste0(gsub(" ", "-", tolower(title)),"-perf-all.pdf"), width=8, height=6)
}

######## different time log format 

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
