
#$SRC_DIR/INSTALL
#cd $SRC_DIR/cpp
#make CC=$CC

export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
#export 
echo =============================
#vendor/htslib-1.11/configure
#echo start ls -------
./INSTALL
#echo end ls -----
#make CC=$CC CXX=$CXX -C $SRC_DIR/cpp
#make INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses -I$SRC_DIR/vendor/htslib-1.11" LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo -lz" LIBPATH="-L$PREFIX/lib" CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib" -C$SRC_DIR/cpp/

#cd ${SRC_DIR}/vendor/htslib-1.11
#./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
#cd $SRC_DIR/cpp
#make CC=$CC CXX=$CXX
#cd -
echo ==============================
#make INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses  LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo" LIBPATH="-L$PREFIX/lib" CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib" -C$SRC_DIR/cpp/ 
#cd -
cp -rf $SRC_DIR/cpp/msisensor-pro $SRC_DIR/binary/
#$SRC_DIR/vendor/htslib-1.11/configure
#make -C$SRC_DIR/vendor/htslib-1.11
#make INCLUDES="-I$PREFIX/include -I$PREFIX/include/ncurses -I$SRC_DIR/vendor/htslib-1.11" LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo" LIBPATH="-L$PREFIX/lib" CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -I$PREFIX/include -L$PREFIX/lib" -C$SRC_DIR/cpp/ 
#make CC=$CC
#$SRC_DIR/INSTALL
cp $SRC_DIR/cpp/msisensor-pro $PREFIX/bin
