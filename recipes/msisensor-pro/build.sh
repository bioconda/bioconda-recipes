export CPATH=${PREFIX}/include
export INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses"
export LDFLAGS="-L$PREFIX/lib -ltinfo"
export LIBRARY_PATH=${PREFIX}/lib
export CPPFLAGS="-I$PREFIX/include"

make
cp msisensor-pro $PREFIX/bin
