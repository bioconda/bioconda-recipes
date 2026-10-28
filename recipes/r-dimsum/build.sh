$R CMD INSTALL --build .
mkdir -p $PREFIX/bin
mv DiMSum* $PREFIX/bin/
