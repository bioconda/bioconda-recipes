export CPATH=${PREFIX}/include
export INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses"
export LDFLAGS="-L$PREFIX/lib -ltinfo"
export LIBRARY_PATH=${PREFIX}/lib

make CC="${CC}" CXX="${CXX}"
cp msisensor $PREFIX/bin
