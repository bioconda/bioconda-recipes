export TAR=$(which tar)	
export R_GZIPCMD=$(which gzip)	
export R_BZIPCMD=$(which bzip2)	

mkdir -p $PREFIX/bin
cp exec/monocle3 $PREFIX/bin
$R CMD INSTALL --build .
