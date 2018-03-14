export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make
sudo make install