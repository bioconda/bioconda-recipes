#!/bin/bash
set -ex

export LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p $PREFIX/bin

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

sed -i.bak "s/-march=x86-64-v3/-march=${MARCH}/g" src/common/wflign/CMakeLists.txt

cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS="${EXTRA_FLAGS}"
cmake --build build -j "${CPU_COUNT}"

# Libraries aren't getting installed
mkdir -p $PREFIX/lib

ls $SRC_DIR/build/lib/* -lh

# mv $SRC_DIR/build/lib/libwfa2cpp.so.0 $PREFIX/lib
# mv $SRC_DIR/build/lib/libwfa2cpp.so $PREFIX/lib
# mv $SRC_DIR/build/lib/libwfa2.so.0 $PREFIX/lib
# mv $SRC_DIR/build/lib/libwfa2.so $PREFIX/lib
cp $SRC_DIR/build/lib/libwfa2* $PREFIX/lib
cp $SRC_DIR/build/lib/libwflign* $PREFIX/lib

install -v -m 0755 build/bin/* $PREFIX/bin
cp scripts/split_approx_mappings_in_chunks.py $PREFIX/bin
