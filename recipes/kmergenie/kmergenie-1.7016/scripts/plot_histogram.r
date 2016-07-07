#!/usr/bin/Rscript

# get histogram file as argument 1
if(length(commandArgs(trailingOnly=TRUE)) > 0 ) {
    hist.file = commandArgs(trailingOnly=TRUE)[1]
}

if (!exists("hist.file") || is.na(hist.file))
{
     stop("ERROR: no histogram file provided")
}


# arg 2: "--diploid" or nothing
if(length(commandArgs(trailingOnly=TRUE)) > 1 ) {
    if (!exists("is.diploid"))
    {
        is.diploid <- grepl("diploid", commandArgs(trailingOnly=TRUE)[2])
    }
} else {
    if (!exists("is.diploid"))
    {
        is.diploid = F
    }
}

# get max.y as argument 3, or nothing
if(length(commandArgs(trailingOnly=TRUE)) > 2 ) {
    max.y = as.integer(commandArgs(trailingOnly=TRUE)[3])
}

# get max.x as argument 4, or nothing
if(length(commandArgs(trailingOnly=TRUE)) > 3 ) {
    max.x = as.integer(commandArgs(trailingOnly=TRUE)[4])
}

# get min.y as argument 5, or nothing
if(length(commandArgs(trailingOnly=TRUE)) > 4 ) {
    min.y = as.integer(commandArgs(trailingOnly=TRUE)[5])
} else {
    if (!exists("min.y"))
    {
        min.y <- 1000
    }
}

if (!exists("output.format") || is.na(output.format))
{
    output.format <- "pdf"
}

name = paste(hist.file,".",output.format,sep="")
#pdf(name,width=6,height=6, pointsize=fs)

if (output.format == "pdf")
{
    pdf(name)
} else {
    png(name)
}

max.copy = 3
source("est-params.r", chdir=T)
if (is.diploid)
{
    source('model-diploid.r', chdir=T)
} else {
    source('model.r', chdir=T)
}

cov = read.table(hist.file)[,1:2]

#cat("plotting hist file and fit for",hist.file,"\n")

# filter extremes from kmers, i.e. keep only the histogram before copycount = max.copy
cov.mean = est.params(cov)[1]
cov = cov[cov[,1] < 1.25*max.copy*cov.mean,]
max.cov = max(cov[,1]) # maximum abundance in the histogram

if (!exists("max.y"))
{
    min.y <- +Inf
    max.y <- -Inf

    if (!exists("max.x"))
    {
        max.x <- -Inf
        max.x =  max(max.x, round(3*cov.mean))
    }  

    df <- cov[,2]
    min.y = max(1,min(min.y,min(df[1:max.x])))
    max.y = max(max.y, max(df[1:max.x])) #or, use round(100*df[,2][cov.mean])
}

#cat("max.x,min.y,max.y",paste(max.x,min.y,max.y),"\n")

covNormalized = cov$V2[1:max.x]
sum.cov = sum(as.numeric(covNormalized))
par(cex=1.5)

if (max(covNormalized, na.rm=TRUE) == 0 )
{
    # when there's nothing to plot
    quit()
}

# histogram
# remove warning because of 0 values
suppressWarnings ( plot(covNormalized, type='h', col=rgb(0.4,0.4,0.4), log='y', ylab='Number of kmers', xlab='Abundance', axes = FALSE) )
 # xlim=c(1,max.x), ylim=c(min.y,max.y))

axis(side=1)
axis(side=2)


# extract value of k from the well-named histogram
# don't have time for an elegant solution
substrRight <- function(x, n){
    substr(x, nchar(x)-n+1, nchar(x))
}
hist_base = basename(hist.file)
splitted = strsplit(hist_base,"-k")[[1]]
txt = paste("k=",gsub("[^0-9]", "", splitted[length(splitted)]))
mtext(txt,side=3,adj=1,cex=2)
#mtext(basename(hist.file),side=3,line=1.5,at=0,cex=1)

# fits

fit_file = paste(dirname(hist.file),"/fit.dat-",basename(hist.file),sep="")

if (file.exists(fit_file))
{
    load(file=fit_file) # load params
    x <- params
    p = list(zp.copy=x[1], p.e=x[2], shape.e=x[3], scale.e=x[4], u.v=x[5], sd.v=x[6])

    probs.err = model(params)$probs.err
    probs.good = model(params)$probs.good
    p.e = p$p.e
    all.dist = p.e * probs.err + (1 - p.e) * probs.good

    if (is.diploid)
    {
        p.d = x[7]
        probs.het.good = (1 - p.e) * (p.d) * model(params)$probs.het.good
        probs.hom.good = (1 - p.e) * (1 - p.d) * model(params)$probs.hom.good
    }

    lines(x=cov[,1][1:max.x], y=all.dist[1:max.x] * sum.cov, col='red', lwd=2.7) # fit

    if (is.diploid)
    {
        lines(x=cov[,1][1:max.x], y=probs.het.good[1:max.x] * sum.cov, col='blue', lwd=4, lty=2)
        lines(x=cov[,1][1:max.x], y=probs.hom.good[1:max.x] * sum.cov, col='darkgreen', lwd=4, lty=4)
    }
}
