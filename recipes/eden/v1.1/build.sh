export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
sed -i "s/-c EDeN.cc/$CFLAGS $LDFLAGS -c EDeN.cc/" Makefile
make
mkdir -p ${PREFIX}/bin
cp EDeN ${PREFIX}/bin
