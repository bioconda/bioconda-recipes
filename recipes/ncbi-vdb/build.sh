export ROOT=$PREFIX
./configure --prefix=$PREFIX/ --build-prefix=$PWD/ncbi-outdir/ --with-ngs-sdk-prefix=$PREFIX 
make
make install
make -C test/vdb
