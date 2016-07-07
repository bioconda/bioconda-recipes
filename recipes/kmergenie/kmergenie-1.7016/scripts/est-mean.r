############################################################
# est.mean
# from Quake
# with improvements by Anton Korobeynikov
#
# Estimate the coverage mean by finding the max past the
# first valley.
############################################################
est.mean = function(d) {
  hc <- smooth(d[,2])

  # find first valley (or right before it)
  valley = hc[1]
  i = 2
  while(hc[i] < valley) {
    valley = hc[i]
    i = i + 1
  }

  # return max over the rest
  max.hist = hc[i]
  max.cov = i
  valley.pos = i
  while(i <= length(hc)) {
    if(hc[i] > max.hist) {
      max.hist = hc[i]
      max.cov = i
    }
    i = i + 1
  }

  c(max.cov, valley.pos)
}
