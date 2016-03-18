require(ggplot2)
library(gridExtra)

includeExtraDatasets <- TRUE

grid_arrange_shared_legend <- function(...) {
    plots <- list(...)
    g <- ggplotGrob(plots[[1]] + theme(legend.position="bottom"))$grobs
    legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
    lheight <- sum(legend$height)
    grid.arrange(
        do.call(arrangeGrob, lapply(plots, function(x)
            x + theme(legend.position="none"))),
        legend,
        ncol = 1,
        heights = unit.c(unit(1, "npc") - lheight, lheight))
}

df <- read.table("data_frame.txt", header=T)

if (!includeExtraDatasets) {
    df <- df[df$dataset != "bench1" & df$dataset != "bench2" & df$dataset != "old",]
}

models <- c("GTR", "GTR.G", "GTR.I", "GTR.G.I")
modelLabels <- c("GTR", "GTR+G", "GTR+I", "GTR+G+I")
runs <- levels(df$run)

for (run in runs) {

    pdf(paste(run,"_summary.pdf",sep=""), width=7, height=7, onefile=F)
    p <- list()
    for (m in 1:length(models)) {
        p[[m]] <- ggplot(df[df$run==run & df$model==models[m],])
        p[[m]] <- p[[m]] + geom_bar(aes(dataset, time, fill=version),
                                    stat="identity", position="dodge")

        if (includeExtraDatasets)
            p[[m]] <- p[[m]] + scale_y_log10()

        p[[m]] <- p[[m]] + theme(axis.text.x = element_text(angle=90, vjust=0.5, hjust=1))
        p[[m]] <- p[[m]] + labs(title=modelLabels[m], x="Dataset", y="Time (seconds)")
    }
    grid_arrange_shared_legend(p[[1]], p[[2]], p[[3]], p[[4]])
    dev.off()

}
