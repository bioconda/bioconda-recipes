export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd build
chmod +x p4utils.pl
sed -i.bak "s#gcc#${CC}#g;s#g++#${CXX}#g" "tmakelib/linux-g++-64/tmake.conf"
make linux-g++-64 BINDIR=$PREFIX/bin LIBDIR=$PREFIX/lib CC=$CC CXX=$CXX TMAKE_CXX=$CXX
