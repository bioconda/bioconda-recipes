# get histogram file as argument 1
if(length(commandArgs(trailingOnly=TRUE)) > 0) {
  hist.file = commandArgs(trailingOnly=TRUE)[1]
} else {
  if (is.na(hist.file))
  {
      stop("ERROR: no histogram file provided")
  }
}

# arg 2: "--diploid" or not
if(length(commandArgs(trailingOnly=TRUE)) > 0 ) {
  is.diploid <- grepl("diploid", commandArgs(trailingOnly=TRUE)[2])
} else {
  if (is.na(is.diploid))
  {
      is.diploid = F
  }
}

cat("histogram file:",hist.file,"\n")

options(scipen=999) # disable exponential notation

source("fit-histogram.r", chdir=T)

source("cutoff.r", chdir=T)

abundances <- as.numeric(cov[,2])

probs.good = model(params)$probs.good
dist.below.cutoff = sum(probs.good[1:max(1,cut-1)])
cutoff_scale = (sum(probs.good)-dist.below.cutoff) # remove the portion of genomic k-mers below cutoff
cat("sum probs good",sum(probs.good))
cutoff_scale = 1 # let's not discard genomic k-mers that are below cut-off for now (TODO: investigate what happens if we remove that line)

write(cat("\ncutoff_scale:",cutoff_scale,"\n"), stderr())
est.genomic = floor((1-p.err) * sum(abundances) * cutoff_scale )

# another way to estimate est.genomic -- I'm not using it 
#probs.err = model(params)$probs.err
#est.genomic.bak = est.genomic
#prob.kmer.good = (1-p.err)*probs.good / (p.err * probs.err + (1-p.err)*probs.good) # for each abundance, probability that a k-mer is good
#est.genomic = sum( prob.kmer.good[cut:length(prob.kmer.good)] * abundances[cut:length(abundances)] )
#write(cat("before reest", est.genomic.bak, "after reest",est.genomic), stderr())

if (is.diploid)
{
    het.proportion = params[7]
# correction for heterozygosity
# suppose genome of size G kmers has 2*X heterozygous kmers and Y homozygous kmers,
# written as G = 2*X + Y, we know that p.d in model-diploid.r is 2X/G,
# then Y = G*(1-p.d)
    est.genomic.Y = est.genomic * (1-het.proportion) 
    est.genomic.X = het.proportion * est.genomic / 2
    est.genomic = floor(est.genomic.Y + est.genomic.X)
}


# now recover copynumber=1 genomic kmers
truncate.copy <- 1
probs.good.norepeat = model(params)$probs.good
area.norepeat = sum(probs.good.norepeat)
est.genomic.nonrepeat = floor((1-p.err) * sum(abundances) * (area.norepeat))
est.genomic.repeat = est.genomic - est.genomic.nonrepeat

if (est.genomic.repeat < 0) # takes into account a density bug into model.r
{
    est.genomic.nonrepeat = NA
    est.genomic.repeat = NA
}

cat("non-repeated genomic distinct kmers: ",est.genomic.nonrepeat,"\n")
cat("repeated genomic distinct kmers: ",est.genomic.repeat,"\n")

# do a small computation that "might" reflect how good the fit is
size = length(abundances)
fit_file = paste(dirname(hist.file),"/fit.dat-",basename(hist.file),sep="")
load(file=fit_file) # load params
x <- params
p = list(zp.copy=x[1], p.e=x[2], shape.e=x[3], scale.e=x[4], u.v=x[5], sd.v=x[6])
probs.err = model(params)$probs.err
probs.good = model(params)$probs.good
p.e = p$p.e
all.dist = (p.e * probs.err + (1 - p.e) * probs.good ) * sum(abundances)
sumabsdiff = sum ( abs ( abundances[cut:size] - all.dist[cut:size] ) )
cat("sum of absolute differences of fit:",sumabsdiff,"\n")


cat(round(est.genomic,digits=0))
