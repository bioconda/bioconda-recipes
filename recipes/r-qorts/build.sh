  mv DESCRIPTION DESCRIPTION.old
  grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

  $R CMD INSTALL --build QoRTs_1.3.6.tar.gz
