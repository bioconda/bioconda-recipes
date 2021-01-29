#!/bin/bash

#Whole new build that hopefully can use installed libraries and end this craziness for good.

if [ "$(uname)" == "Darwin" ]; then
    # MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14.
    export CXXFLAGS="${CXXFLAGS} CXX=clang++" 
    export CC=clang 
    export CC_LD=lld 
    meson build --buildtype debug
fi


export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include

export LDFLAGS="-L$PREFIX/lib -L\$(LIB_DIR) -lvcflib -lhts -lpthread -lz -lm -llzma -lbz2"
export INCLUDES="-I . -Ihtslib -I$PREFIX/include -Itabixpp/htslib -I\$(INC_DIR) -L. -Ltabixpp/htslib"
export LIBPATH="-L. -Lhtslib -L$PREFIX/lib"
export CXXFLAGS="-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x"

#Updating some commands with inspiration from the pbmm2 build

meson build/ --buildtype debug --libdir lib --prefix "${PREFIX}"

cd build
ninja -v
ninja -v install






