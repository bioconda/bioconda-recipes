export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
make
cp olego $PREFIX/bin
cp olegoindex $PREFIX/bin
chmod +x $PREFIX/bin/olego
chmod +x $PREFIX/bin/olegoindex