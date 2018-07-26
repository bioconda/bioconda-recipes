export CPATH=${PREFIX}/include
export INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses"
export LDFLAGS="-L$PREFIX/lib -ltinfo"
make
cp msisensor $PREFIX/bin
