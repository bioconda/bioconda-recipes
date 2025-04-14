#!/bin/bash
set -ex
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

case $(uname -m) in
    x86_64)
        EXTRA_FLAGS="-march=sandybridge -Ofast"
        MARCH="sandybridge"
        ;;
    *)
        EXTRA_FLAGS="-march=native -Ofast"
        MARCH="native"
        ;;
esac

sed -i "s/-march=x86-64-v3/-march=${MARCH}/g" src/common/wflign/deps/WFA2-lib/Makefile
cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS="${EXTRA_FLAGS}"
cmake --build build -j ${CPU_COUNT}

# Libraries aren't getting installed
mkdir -p $PREFIX/lib

ls $SRC_DIR/build/lib/* -lh

# mv $SRC_DIR/build/lib/libwfa2cpp.so.0 $PREFIX/lib
# mv $SRC_DIR/build/lib/libwfa2cpp.so $PREFIX/lib
# mv $SRC_DIR/build/lib/libwfa2.so.0 $PREFIX/lib
# mv $SRC_DIR/build/lib/libwfa2.so $PREFIX/lib
cp $SRC_DIR/build/lib/libwfa2* $PREFIX/lib
cp $SRC_DIR/build/lib/libwflign* $PREFIX/lib

mkdir -p $PREFIX/bin
cp build/bin/* $PREFIX/bin
cp scripts/split_approx_mappings_in_chunks.py $PREFIX/bin
