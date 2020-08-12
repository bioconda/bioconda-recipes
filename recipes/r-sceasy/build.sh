export TAR=$(which tar)
export R_GZIPCMD=$(which gzip)
export R_BZIPCMD=$(which bzip2)

$R CMD INSTALL --build .
