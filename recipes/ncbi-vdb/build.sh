export ROOT=$PREFIX
./configure --prefix=$PREFIX/ --build=$PREFIX/share/ncbi --with-ngs-sdk-prefix=$PREFIX 
make
make install
make -C test/vdb
