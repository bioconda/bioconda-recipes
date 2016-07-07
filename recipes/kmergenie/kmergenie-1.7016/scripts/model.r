############################################################
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

perr <- function(x, shape, scale) {
  (1 + shape*(x-1)/scale) ^ (-1/shape) - (1 + shape*(x)/scale) ^ (-1/shape)
}

truncate.copy <- 0

pgood <- function(x, max.copy, zp.copy, u.v, sd.v, shape.v) {
  # dcopy = heavy tail of the copy counts = heights of the zeta distribution with parameter zp.copy
  dcopy <- dzeta(1:max.copy, p=zp.copy)
  dcopy <- dcopy / sum(dcopy)

  # probs = matrix with max_abundance rows and max_copy_count columns, initialized to 0
  # it describes the mixture of distributions (after we sum all columns)
  
  if (truncate.copy == 0)
  {
     until.copy <- max.copy
  }
  else
  {
     until.copy <- truncate.copy
  }

  probs <- matrix(0, nrow = length(x), ncol=until.copy)

  for (copy in 1:until.copy) {
    # columns (copy) of = normal distribution correspond to copycount
    # dnorm(x,mean,sd) = height of the proba distribution at point x
    probs[, copy] = dcopy[copy] * 2 * dnorm(x, mean=(copy*u.v), sd=sqrt(copy)*sd.v) * pnorm((x - copy*u.v)*shape.v / (sqrt(copy)*sd.v))
    # FIXME: dnorm may be > 1 (consider the height of a normal distribution with extremly small sd), so this probabilty may exceed 1 with small datasets
}

  rowSums(probs)
}

############################################################
# model 
############################################################
model = function(params) {
  zp.copy = params[1] # parameter of the zeta distribution, approximating the heavy tail
  p.e = params[2] # "mixture parameter to determine which of the two [erroneous kmers and true kmers] distributions a k-mer coverage will be sampled from"
  shape.e = params[3] # pareto shape
  scale.e = params[4] # pareto scale
  u.v = params[5] # abundance at copy_count=1
  sd.v = params[6] # standard deviation of abundance at copy_count=1
  shape.v = params[7] # shape of the skewed normal at copy_count=1
  
  if (zp.copy <= 1 | shape.e < 0 | sd.v <= 0 | u.v <= 0 | p.e < 0 | p.e > 1 - 1e-9)
    return (list(like=-Inf))
 
  probs.err =  perr(cov[, 1], shape.e, scale.e)
  probs.good = pgood(cov[, 1], max.copy, zp.copy, u.v, sd.v, shape.v)  

  kmers.probs <- p.e * probs.err + (1 - p.e) * probs.good
  logprobs <- log(kmers.probs)

  # for each abundance, multiply each log(sum(row)) by the number of kmers at that abundance
  return (list(like=-sum(logprobs*cov[,2]), probs=kmers.probs, probs.err=probs.err, probs.good=probs.good))
}

modelEM <- function(params, z) {
  # note that p.e is replaced by z
  zp.copy = params[1]
  shape.e = params[2]
  scale.e = params[3]
  u.v = params[4]
  sd.v = params[5]
  shape.v = params[6]

  if (zp.copy < 1+1e-6 | shape.e < 1e-9 | sd.v < 1e-9 | u.v < 1e-9)
    return (list(like=-Inf))
  
  # error
  logprobs <- z * log(perr(cov[, 1], shape.e, scale.e))
  
  # no error
  logprobs <- logprobs + (1 - z)* log(pgood(cov[, 1], max.copy, zp.copy, u.v, sd.v, shape.v))

  -sum(logprobs * cov[, 2])
}

EStep <- function(params) {
  zp.copy = params[1]
  p = params[2]
  shape.e = params[3]
  scale.e = params[4]
  u.v = params[5]
  sd.v = params[6]
  shape.v = params[7]
  
  pe <- p * perr(1:max.cov, shape.e, scale.e)
  pe / (pe + (1 - p) * pgood(1:max.cov, max.copy, zp.copy, u.v, sd.v, shape.v))
}

