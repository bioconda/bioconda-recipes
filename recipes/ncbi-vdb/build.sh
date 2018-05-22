export ROOT=$PREFIX
./configure --prefix=$PREFIX/ --with-ngs-sdk-prefix=$PREFIX 
make
make install
make -C test/vdb
