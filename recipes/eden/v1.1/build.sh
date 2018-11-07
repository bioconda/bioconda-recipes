export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
