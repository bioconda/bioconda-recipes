
#$SRC_DIR/INSTALL
#cd $SRC_DIR/cpp
#make CC=$CC

export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
cd ${SRC_DIR}/vendor/htslib-1.11
autoheader
autoconf
./configure 
cd $SRC_DIR/cpp
make CC=$CC CXX=$CXX
cd -
cp -rf $SRC_DIR/cpp/msisensor-pro $SRC_DIR/binary/
cp -rf $SRC_DIR/cpp/msisensor-pro $PREFIX/bin
