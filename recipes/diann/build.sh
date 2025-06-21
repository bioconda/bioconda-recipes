#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

tar xvf data.tar.gz

DIANN_PATH=$(find . -type f -executable | grep -P "diann-[^/]*$")
DIANN_DIR=$(dirname $DIANN_PATH)

#mv $DIANN_DIR/diann-1.8.1 $PREFIX/bin/
cp -R $DIANN_DIR/* $PREFIX/bin/

# fix for libgomp
echo "Remove libgomp-52f2fd74.so.1"
rm -f ${PREFIX}/bin/libgomp-52f2fd74.so.1
echo "Create symlink libgomp-52f2fd74.so.1"
ln -s ${PREFIX}/bin/libgomp.so.1.0.0 ${PREFIX}/bin/libgomp-52f2fd74.so.1

chmod +x $PREFIX/bin/diann-1.8.1

#cp -R $BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/lib64/libm.so.6 ${PREFIX}/lib/libm.so.6
#cp -R $BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/lib64/libm.so.6 ${PREFIX}/bin/libm.so.6

ldd "$(which diann-1.8.1)"
patchelf --print-needed $(which diann-1.8.1)