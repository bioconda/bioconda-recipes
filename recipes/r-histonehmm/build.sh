find $PREFIX -name Rcpp.h
mkdir ~/.R
echo -e "CC=$CC -I$PREFIX/include
FC=$FC
CXX=$CXX -I$PREFIX/include
CXX98=$CXX -I$PREFIX/include
CXX11=$CXX -I$PREFIX/include
CXX14=$CXX -I$PREFIX/include" > ~/.R/Makevars
$R CMD INSTALL --build .
