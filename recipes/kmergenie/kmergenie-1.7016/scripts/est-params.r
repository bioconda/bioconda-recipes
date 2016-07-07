# Find the initial estimates of the parameters
# by Anton Korobeynikov
# modified by R.C.

source("est-mean.r", chdir=T)


find_peaks <- function (x, m = 5){
    shape <- diff(sign(diff(x, na.pad = FALSE)))
    pks <- sapply(which(shape < 0), FUN = function(i){
                  z <- i - m + 1
                  z <- ifelse(z > 0, z, 1)
                  w <- i + m + 1
                  w <- ifelse(w < length(x), w, length(x))
                  if(all(x[c(z : i, (i + 2) : w)] <= x[i + 1])) return(i + 1) else return(numeric(0))
})
    pks <- unlist(pks)
    pks
}# from http://stats.stackexchange.com/questions/22974/how-to-find-local-peaks-valleys-in-a-series-of-data

est.params <- function(d, is.diploid=F, method=1) {
  # First, find the valley and first coverage maximum using the smoothed histogram
  v <- est.mean(d)
  max.cov <- v[1]
  valley <- v[2]

  # Now find the median coverage value for everything past the valley
  vals <- d[,2]
  cvals <- cumsum(vals[(valley+1):length(vals)])
  before_median <- c(0,which(cvals < cvals[length(cvals)] / 2))
  mcov <- valley + max(before_median)

  # The new estimate of the mean coverage is the max of two estimates
  max.cov <- max(mcov, max.cov)

  # for diploid organism, there is a risk that max.cov corresponds to heteozygous peak
  # (when high het rate, hom peak is lower than het peak)
  # in that case, here are some heuristics to address this effect.
  # these heuristics are only applied when the method parameter is set to > 1
  found_peaks = find_peaks(d[,2])
  if (is.diploid && length(found_peaks) >= 2 && method > 1 )
    #that second check is just to avoid a crash; ofc there will be more than 2 peaks. 
    #and actually, the hom peak might not even be detected.
     #that third check is to disable this heuristic in vanilla method
  {
      p1 = found_peaks[1]
      p2 = found_peaks[2]
      max.cov.is.first.peak = (abs(max.cov - p1) < abs(max.cov - p2))
      second.peak.is.roughly.at.2x = (1.5 <= (p2 / p1) && (p2/p1) <= 2.5)
      if (max.cov.is.first.peak)
      {
          if (second.peak.is.roughly.at.2x)
          {
              cat("max cov (",max.cov,") is closer to first detected peak (",p1,") than to second",p2,". since it's a diploid organism, let's pick second peak\n")
              max.cov = p2
          }
          else
          {
              cat("max cov (",max.cov,") is closer to first detected peak (",p1,") and second peak (",p2,") seems quite far. since it's a diploid organism, let's assume we are in the situation where second peak is 'hidden' and we'll set it to ",p1*2,"\n")
              max.cov = p1 * 2
          }
      }

     #in diploid mode, i believe the following is a more robust estimation
     # it uses estimation of sd from first (het) peak; symmetrizied
     mvals <- c(vals[max.cov/2], vals[(valley+1):(max.cov/2 - 1)] + rev(vals[(valley+1):(max.cov/2 - 1)]))
     cvals <- cumsum(mvals)
     before_median <- c(0,which(cvals < cvals[length(cvals)] / 2))
     cov.sd <- 1.4826 * max(before_median - 1)
     cov.sd <- max(cov.sd,1.4826) # appears needed, sd=0 provokes crash in EMOpt
     cov.sd = cov.sd * sqrt(2) #  to adjust for hom peak, 2x larger mean. so i'm multiplying stdev by sqrt(2), seems to make sense.
     if (method == 3) cov.sd = cov.sd * sqrt(2) # inflate sd just to test
  }
  else
  { #haploid sd estimation

      # Try to estimate the deviation calculating the median absolute difference wrt
      # the calculated max.cov
      mvals <- c(vals[max.cov], vals[(max.cov+1):(2*max.cov-valley-1)] + rev(vals[(valley+1):(max.cov - 1)]))
      cvals <- cumsum(mvals)
      before_median <- c(0,which(cvals < cvals[length(cvals)] / 2))
      cov.sd <- 1.4826 * max(before_median - 1)
      cov.sd <- max(cov.sd,1.4826) # appears needed, sd=0 provokes crash in EMOpt
  }

  # The initial estimate of erroroneous probability is just the ratio of k-mers
  # before the valley
  p.err <- sum(as.numeric(vals[1:valley])) / sum(as.numeric(vals))
  
  # FIXME: Estimate the skewness for skew normal
  # gamma <- min(0.9, abs(<sample skew>))
  # delta <- sqrt(pi / 2 * (gamma ^ (2/3)) / (gamma ^ (2/3) + ((4 - pi)/2) ^ (2/3)))
  # shape <- sign(<sample skew>) * delta / sqrt(1 - delta ^2)
  shape <- 0
  c(max.cov, cov.sd, p.err, shape)
}
