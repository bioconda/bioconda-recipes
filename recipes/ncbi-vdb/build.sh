export ROOT=$PREFIX
./configure --prefix=$PREFIX/ --with-ngs-sdk-prefix=$PREFIX/share/ncbi/
make
make install
make -C test/vdb
