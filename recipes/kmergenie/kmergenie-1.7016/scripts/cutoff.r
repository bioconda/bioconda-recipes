 
ratio.goal = 100 # golden value (used to be 1, found 100 to be better for minia/bacterial genomes)

# get histogram file as argument 1
if(length(commandArgs(trailingOnly=TRUE)) > 0 ) {
    hist.file = commandArgs(trailingOnly=TRUE)[1]
}

if (!exists("hist.file") || is.na(hist.file))
{
     stop("ERROR: no histogram file provided")
}

# arg 2: "--diploid" or "--haploid" or "--no-fit" or nothing
if(length(commandArgs(trailingOnly=TRUE)) > 1 ) {
    if (!exists("is.diploid"))
    {
        is.diploid <- grepl("diploid", commandArgs(trailingOnly=TRUE)[2])
    }
    if (!exists("no.fit"))
    {
        no.fit <- grepl("no-fit", commandArgs(trailingOnly=TRUE)[2])
    }
} else {
    if (!exists("is.diploid"))
    {
        is.diploid = F
    }
    if (!exists("no.fit"))
    {
        no.fit <- F
    }
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
# filter extremes from kmers, i.e. keep only the histogram before copycount = max.copy
cov.mean = est.params(cov)[1]
cov = cov[cov[,1] < 1.25*max.copy*cov.mean,]
max.cov = max(cov[,1]) # maximum abundance in the histogram


fit_file = paste(dirname(hist.file),"/fit.dat-",basename(hist.file),sep="")
load(file=fit_file) # load params
x <- params
p = list(zp.copy=x[1], p.e=x[2], shape.e=x[3], scale.e=x[4], u.v=x[5], sd.v=x[6])
cat("p$u.v:", p$u.v, "\n")
cat("p$p.e:", p$p.e, "\n")

probs.err = model(params)$probs.err
probs.good = model(params)$probs.good
p.e = p$p.e
all.dist = p.e * probs.err + (1 - p.e) * probs.good

cat("abundance    ratio_of_erroneous_over_correct_kmers\n")
cutoffs <- function(probs.err, probs.good,n) {
  ratios = numeric(n)
  for (i in 1:n) {
    #ratios[i] = probs.err[i] / sum(probs.good[i])
    # suggested by claire: p.e*probs.err[i] / ((1-p.e)*all.probs.good[i])
    ratios[i] = (p.e*probs.err[i]) / ((1-p.e)*sum(probs.good[i]))
    cat(i," ",ratios[i],"\n")
  }
  
  return (ratios)
}

cut = max((1:p$u.v)[cutoffs(probs.err, probs.good, p$u.v) >= ratio.goal])
cut = max(0,cut)

cat("cutoff:", cut,"\n") # don't remove that print, the "decide" script parses it

