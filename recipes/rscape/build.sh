./configure --disable-avx512 --prefix=$PREFIX
make clean
make V=1
make install
