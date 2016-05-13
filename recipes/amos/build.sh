rm -r test tutorial
export LDFLAGS="-L$PREFIX/lib"
export CPPFLAGS="-I$PREFIX/include"
./bootstrap
./configure \
    --prefix=$PREFIX 
make
make install
