#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# Ensure cmake sets use_new_cxx to 1
sed -i.bak "s/4.3/4.0/" CMakeLists.txt

rm -rf build
mkdir build
cd build
cmake ..
make -j8

binaries="\
simka \
simkaCount \
simkaCountProcess \
simkaMerge \
simkaMin \
"

mkdir -p $PREFIX/bin/
for i in $binaries; do cp $SRC_DIR/build/bin/$i $PREFIX/bin/; done
for i in $binaries; do chmod +x $PREFIX/bin/$i; done

cp $SRC_DIR/simkaMin/*.py $PREFIX/bin/
