#!/bin/bash
set -e  # Exit on error

export CPATH="${PREFIX}/include"

export LDFLAGS="-L${PREFIX}/lib"

export CFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"
export CPPFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"
export CXXFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"

ln -s ${PREFIX}/lib/libncurses.so ${PREFIX}/lib/libcurses.so

mkdir -p "${PREFIX}/bin"

pushd submodules/src/

make clean
make
install -v -m 0755 bam2prof "${PREFIX}/bin/"
popd 

install -v -m 0755 addeam-bam2prof.py addeam-cluster.py "${PREFIX}/bin/"


