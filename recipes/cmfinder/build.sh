mkdir -p $PREFIX/bin
#./configure --prefix=$PREFIX
make
cp bin/* $PREFIX/bin/ 
