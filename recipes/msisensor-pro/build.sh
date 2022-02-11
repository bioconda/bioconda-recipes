
#$SRC_DIR/INSTALL
#cd $SRC_DIR/cpp
#make CC=$CC

export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
#export CC=${PREFIX}/bin/gcc
#export CXX=${PREFIX}/bin/g++
echo ==============================
#which gcc
#which g++
#echo ==============================
cd ${SRC_DIR}/vendor/htslib-1.11
autoheader
autoconf
./configure 
make 


cd ${SRC_DIR}/cpp

#if [ `uname -s` == "Darwin" ];
#then
# 	sed -i 's|-Wl,-rpath=${HTSLIB}||g' ./makefile 	   
#	sed -i 's|htsfile ||g' ./makefile
#
#fi
#cat ./makefile
echo "=========start msisensor-pro make ========="

make CC=$CC CXX=$CXX
cd -
cp -rf $SRC_DIR/cpp/msisensor-pro $SRC_DIR/binary/
cp -rf $SRC_DIR/cpp/msisensor-pro $PREFIX/bin
