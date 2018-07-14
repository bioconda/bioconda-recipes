export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make
cp olego $PREFIX/bin
cp olegoindex $PREFIX/bin
chmod +x $PREFIX/bin/olego
chmod +x $PREFIX/bin/olegoindex