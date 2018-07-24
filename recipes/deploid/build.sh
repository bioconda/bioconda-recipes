export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./bootstrap
make
make install
