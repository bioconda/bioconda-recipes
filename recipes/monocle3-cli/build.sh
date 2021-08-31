mkdir -p $PREFIX/bin
cp exec/monocle3 $PREFIX/bin
$R CMD INSTALL --build .
