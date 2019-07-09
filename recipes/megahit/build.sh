#!/bin/sh

export CPATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

rm -rf build
mkdir -p build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release
make -j $CPU_COUNT

mv megahit $PREFIX/bin
mv megahit_core $PREFIX/bin
mv megahit_core_no_hw_accel $PREFIX/bin


#mv megahit $PREFIX/bin
#mv megahit_asm_core $PREFIX/bin
#mv megahit_sdbg_build $PREFIX/bin
#mv megahit_toolkit $PREFIX/bin

#mkdir -p $PREFIX/share/megahit
#mv example $PREFIX/share/megahit
