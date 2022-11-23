export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd build
chmod +x p4utils.pl
make linux-g++-64 BINDIR=$PREFIX/bin LIBDIR=$PREFIX/lib CC=$CC CXX=$CXX
