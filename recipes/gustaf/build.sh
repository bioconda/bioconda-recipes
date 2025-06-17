#!/bin/bash
if [[ ${target_platform} == "linux-aarch64" ]]; then

mkdir -p $SRC_DIR/install

cd $SRC_DIR

mkdir build && cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$SRC_DIR/install

make -j 16 && make install

cd $SRC_DIR/install/bin

binaries="\
gustaf \
gustaf_mate_joining \
"

mkdir -p $PREFIX/bin

for i in $binaries; do cp $SRC_DIR/install/bin/$i $PREFIX/bin && chmod a+x $PREFIX/bin/$i; done

else

cd $SRC_DIR/bin

binaries="\
gustaf \
gustaf_mate_joining \
"
mkdir -p $PREFIX/bin

for i in $binaries; do cp $SRC_DIR/bin/$i $PREFIX/bin/$i && chmod a+x $PREFIX/bin/$i; done

fi
