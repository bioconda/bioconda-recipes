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

# get histogram file as argument 1
if(length(commandArgs(trailingOnly=TRUE)) > 0 ) {
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
      warning("WARNING: no model provided, using haploid")
      is.diploid = F
  }
}



source("est-params.r", chdir=T)

############################################################
# EM optimization
############################################################

EMOpt <- function(cov, init, maxit = 1000, tol = 1e-9) {
  cpar <- init
  lik <- +Inf
  for (i in 1:maxit) {
    z <- EStep(cpar)

    p <- sum(z * cov[,2]) / sum(cov[,2])
    cpar = cpar[-2]
    #cat(cpar,"\n")
    opt <- optim(cpar, modelEM,
                 z = z,
                 control=list(trace=0, maxit=10000))
    cpar <- append(opt$par, p, 1)
    clik <- model(cpar)$like
    #cat("Log-likelihood:", clik, "\n")
    if (abs(clik - lik) < tol)
      break
    lik <- clik
  }

  cpar
}

############################################################
# this procedure performs the fit 
# returns an optimization object (essentially the found params, and some objective value) 
############################################################

try.fit = 
function(hist.file, is.diploid, method=1)
{
    max.copy = 3

    ############################################################
    # load data
    ############################################################
    cov = read.table(hist.file)[,1:2] 
    cov[,2]=as.numeric(cov[,2])
    params = est.params(cov, is.diploid, method)
    cov.est = params[1]
    sd.est = params[2]
    p.e.est = params[3]
    shape.est = params[4]
    cat("initial estimate of genomic kmers gaussian mean, sd, error proportion, shape:",params,"\n")

    zp.copy.est = 3
    shape.e.est = 3
    scale.e.est = 1

    # filter extremes from kmers, i.e. keep only the histogram before copycount ~30
    cov = cov[cov[,1] < 1.25*max.copy*cov.est,]
    cov <- cov[1:(max(which(cov[,2] != 0))), ]
    max.cov = max(cov[,1]) # maximum abundance in the histogram
    
    assign("max.copy", max.copy, .GlobalEnv) # global variable assignment (needed because model isn't passed max.copy)
    assign("cov", cov, .GlobalEnv) # global variable assignment (needed because model isn't passed cov)
    assign("max.cov", max.cov, .GlobalEnv) # global variable assignment (needed because model isn't passed max.cov either, eh)

    if (is.diploid)
    {
        source('model-diploid.r', chdir=T)
        init <- c(zp.copy.est, p.e.est, shape.e.est, scale.e.est, cov.est, sd.est, .2, (sd.est)**2, 3)
    
    } else {
        source('model.r', chdir=T)
        init <- c(zp.copy.est, p.e.est, shape.e.est, scale.e.est, cov.est, sd.est, shape.est)
    }
    

    #
    use.em <- TRUE
    
    if (is.diploid)
    {
        use.em <- FALSE
    }
    
    if (use.em) {
        opt <- list(par = EMOpt(cov, init))
    } else {
        # Quake's optimization
        #cat("init",init,"\n")
        opt = 
        tryCatch(optim(init, function(x) model(x)$like, method="BFGS", control=list(trace=1, maxit=1000), hessian=F),
         error=function(e){
                cat("Error during optim\n")
                opt = NaN
         }) 

    }

    #cat('optimization value:',opt$value,"\n")
    opt
}

opt = try.fit(hist.file, is.diploid)

is.successful.fit = function(opt) { is.list(opt) }

#if organism is diploid, try a few other fit possibilities 
# i feel like this code could be made more generic later
if (is.diploid)
{   
    opt2 = try.fit(hist.file, is.diploid, method=2)
    opt3 = NaN
    if (!is.successful.fit(opt) && !is.successful.fit(opt2))
    {
        opt3 = try.fit(hist.file, is.diploid, method=3) # desperate attempt
    }

    cat("opt results:\n")
    if (is.successful.fit(opt))
        cat("opt:",opt$value,"-",opt$par,"\n")
    if (is.successful.fit(opt2))
        cat("opt2:",opt2$value,"-",opt2$par,"\n")
    if (is.successful.fit(opt3))
        cat("opt3:",opt3$value,"-",opt3$par,"\n")

    if (!is.successful.fit(opt)) # ugly error handling
        opt = opt2
    if (!is.successful.fit(opt))
        opt = opt3

    if ((is.successful.fit(opt)) && (is.successful.fit(opt2)) && opt2$value < opt$value)
        opt = opt2 #pick best method
    if ((is.successful.fit(opt)) && (is.successful.fit(opt3)) && opt3$value < opt$value)
        opt = opt3
    if (!is.successful.fit(opt))
        stop("could not find any way to fit this histogram\n")

}

if (is.diploid)
{
    cat("final proportion of het kmers:",opt$par[7],"\n")
    cat("final genomic kmers gaussian mean:",opt$par[5],"\n")
}

params <- opt$par
fit_file <- paste(dirname(hist.file),"/fit.dat-",basename(hist.file),sep="")
save(params,file=fit_file)

p.err = params[2] # for both haploid and diploid
