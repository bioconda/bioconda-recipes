#!/usr/bin/env bash
set -e  # Exit on error

# export PREFIX="$PREFIX"
# export BUILD_PREFIX="$BUILD_PREFIX"
# export CONDA_PREFIX="$BUILD_PREFIX"
# export SRC_DIR="$SRC_DIR"



# export CPATH="${BUILD_PREFIX}/include"

# export LDFLAGS="-L${BUILD_PREFIX}/lib"

# export CFLAGS="-I${SRC_DIR}/submodules/lib/libgab -I${BUILD_PREFIX}/include -I${BUILD_PREFIX}/include/htslib"
# export CPPFLAGS="-I${SRC_DIR}/submodules/lib/libgab -I${BUILD_PREFIX}/include -I${BUILD_PREFIX}/include/htslib"
# export CXXFLAGS="-I${SRC_DIR}/submodules/lib/libgab -I${BUILD_PREFIX}/include -I${BUILD_PREFIX}/include/htslib"

#ln -s ${BUILD_PREFIX}/lib/libncurses.so ${BUILD_PREFIX}/lib/libcurses.so

mkdir -p "${PREFIX}/bin"

pushd submodules/src/

BUILD_PREFIX="$BUILD_PREFIX" \
CONDA_PREFIX="$BUILD_PREFIX" \
PREFIX="$PREFIX" \
SRC_DIR="$SRC_DIR" \
CXXFLAGS="-I${SRC_DIR}/submodules/lib/libgab \
          -I${CONDA_PREFIX}/include      \
          -I${CONDA_PREFIX}/include/htslib" \
LDFLAGS="-L${CONDA_PREFIX}/lib" \

make clean all

# make clean
# make
install -v -m 0755 bam2prof "${PREFIX}/bin/"
popd 

install -v -m 0755 addeam-bam2prof.py addeam-cluster.py "${PREFIX}/bin/"


