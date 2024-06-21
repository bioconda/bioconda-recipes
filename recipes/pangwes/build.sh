#!/bin/bash

set -xe

if [[ $target_platform == osx-* ]]; then
    for toolname in "otool" "install_name_tool"; do
        tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname")
        mv "${tool}" "${tool}.bak"
        ln -s "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
    done
fi
# build and install PAN-GWES
make -C sw/pangwes -j ${CPU_COUNT}

which llvm-otool
llvm-otool --version

mkdir -p ${PREFIX}/bin
cp $SRC_DIR/sw/pangwes/bin/unitig_distance $PREFIX/bin/unitig_distance
cp $SRC_DIR/sw/pangwes/bin/gfa1_parser $PREFIX/bin/gfa1_parser
cp ./sw/pangwes/scripts/gwes_plot.r $PREFIX/bin/gwes_plot.r
