export CPATH=${PREFIX}/include
export INCLUDES+="-I$PREFIX/include -I$PREFIX/include/ncurses"
export LDFLAGS="-L$PREFIX/lib -ltinfo"
export LIBRARY_PATH=${PREFIX}/lib
$SRC_DIR/INSTALL
#$SRC_DIR/vendor/htslib-1.11/configure
#make -C$SRC_DIR/vendor/htslib-1.11
#make INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses -I$SRC_DIR/vendor/htslib-1.11" LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo" LIBPATH="-L$PREFIX/lib" CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib" -C$SRC_DIR/cpp/ 
#make CC=$CC
#$SRC_DIR/INSTALL
cp $SRC_DIR/cpp/msisensor-pro $PREFIX/bin
