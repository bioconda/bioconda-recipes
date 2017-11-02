export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export CFLAGS="-O2 -fopenmp -I$PREFIX/include -I"
cd $SRC_DIR/src
make
cd ../

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/

