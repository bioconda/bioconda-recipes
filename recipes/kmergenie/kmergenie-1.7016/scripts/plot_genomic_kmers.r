#!/usr/bin/Rscript

args <- commandArgs(TRUE)
if (length(args)==0) {
print("Usage:")
print("./plot_genomic_kmers.r [histograms.dat]")
quit()
}
name <-args[1]
best_k <-args[2]
ass_s <- args[3]

if(length(commandArgs(trailingOnly=TRUE)) > 3 ) {
    is.png <- grepl("png", commandArgs(trailingOnly=TRUE)[4])
}

if ((!exists("output.format") || is.na(output.format)) && (!exists("is.png") || !is.png))
{
    pdf(paste(name,".pdf",sep=""),width=7,height=7)
} else {
    png(paste(name,".png",sep=""))
}

a <- read.table(name,header=T)
a <- a[order(a$k),]

par(cex=1.5)

plot(data.matrix(a),type='l', ylab = "Number of genomic k-mers",xlab="K-mer size")#, main=basename(name))
abline(v=best_k, col="RED", lty=2)
abline(h=ass_s, col="RED", lty=2)

#lines(a$k,a$genomic.nonrepeated.kmers,lty=2) # buggy for now
#lines(data$k,data$genomic.repeated.kmers)
#legend('topleft',lty=c(1,2), c("Total k-mers","Non-repeated k-mers"))
