#!/bin/bash

set -xe

# build and install PAN-GWES
make -C sw/pangwes -j ${CPU_COUNT}

if [[ $target_platform == osx-* ]]; then
  which llvm-otool
  llvm-otool --version
fi

mkdir -p ${PREFIX}/bin
cp $SRC_DIR/sw/pangwes/bin/unitig_distance $PREFIX/bin/unitig_distance
cp $SRC_DIR/sw/pangwes/bin/gfa1_parser $PREFIX/bin/gfa1_parser
cp ./sw/pangwes/scripts/gwes_plot.r $PREFIX/bin/gwes_plot.r
