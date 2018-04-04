export ROOT=$PREFIX
./configure --prefix=$PREFIX/ --build=$PREFIX/share/ncbi --with-ngs-sdk-prefix=$PREFIX
make install
make test
