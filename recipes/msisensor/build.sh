export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
make
cp msisensor $PREFIX/bin