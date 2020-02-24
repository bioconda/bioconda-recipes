export CPATH=${PREFIX}/include
export INCLUDES+="-I$PREFIX/include -I$PREFIX/include/ncurses -Ivendor/samtools-0.1.19"
export LDFLAGS="-L$PREFIX/lib -ltinfo"
export LIBRARY_PATH=${PREFIX}/lib
make INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses -I$SRC_DIR/vendor/samtools-0.1.19" LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo" LIBPATH="-L$PREFIX/lib" CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib" 
#make CC=$CC
cp msisensor-pro $PREFIX/bin
