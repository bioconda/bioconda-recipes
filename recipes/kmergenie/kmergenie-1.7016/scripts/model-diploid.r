#############################################################
# taken from cov_model.r of the Quake software
# with improvements by Anton Korobeynikov
#
# Read in a file full of kmer coverages, and optimize
# a probabilistic model in which kmer coverage is simulated
# as follows:
#
# 1. Choose error or no as binomial(p.e)
# 2. Choose copy number as zeta(p)
# 3a. If error, choose coverage as my discrete pareto(p)
# 3b. If not, choose coverage as normal(copy*u.v, sqrt(copy)*sd.v)
#
# Finally, output the ratio of being an error kmer vs being
# a non-error kmer for varying levels of low coverage.
############################################################

source("zeta.r", chdir=T)
source('model.r', chdir=T)

derr.old <- function(x, max.cov, shape.e) {
  derr <- diff(1 - 1/(1:(min(max(x), max.cov) + 1))^shape.e)
  derr[x]
}

###########################################################
# model 
############################################################
model = function(params) {
  zp.copy = params[1] # parameter of the zeta distribution, approximating the heavy tail
  p.e = params[2] # "mixture parameter to determine which of the two [erroneous kmers and true kmers] distributions a k-mer coverage will be sampled from"
  shape.e = params[3] # pareto shape
  scale.e = params[4] # pareto scale
  u.v = params[5] # abundance at copy_count=1
  sd.v = params[6] # standard dev of abundance at copy_count=1
  p.d = params[7] # proportion of the genome which is heterozygous
  var.w = params[8] # variance of abundance at copy_count=0.5; for some reason cannot fit with sd
  zp.copy.het = params[9] # heavy tail for het
  # TODO: use skewed normal here too
  

  if(zp.copy <= 1 | shape.e <= 0 | scale.e <= 0 | sd.v <= 0 | var.w <= 0 | zp.copy.het <= 1 | p.e < 1e-9 | p.e > 1 - 1e-9 | u.v <= 0)
    return(list(like=-Inf))

  #probs.err =  perr(cov[, 1], shape.e, scale.e) # for some reason that pareto function doesnt work with model-diploid
  probs.err =  derr.old(cov[, 1], max.cov, shape.e)

  shape.v = 0 # non-skewed
  probs.hom.good = pgood(cov[, 1], max.copy, zp.copy, u.v, sd.v, shape.v)  
  probs.het.good = pgood(cov[, 1], max.copy, zp.copy.het, 0.5*u.v, 0.5*sqrt(var.w), shape.v)  
  probs.good = p.d * probs.het.good + (1-p.d) * probs.hom.good
  kmers.probs <- p.e * probs.err + (1 - p.e) * probs.good
  logprobs <- log(kmers.probs)

  return (list(like=-sum(logprobs*cov[,2]), probs=kmers.probs, probs.err=probs.err, probs.good=probs.good, probs.het.good=probs.het.good, probs.hom.good=probs.hom.good))

}

