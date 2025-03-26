#!/bin/bash
set -e  # Exit on error

export CPATH="${PREFIX}/include"

export LDFLAGS="-L${PREFIX}/lib"

export CFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"
export CPPFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"
export CXXFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

cd submodules/src/

ln -s ${PREFIX}/lib/libncurses.so ${PREFIX}/lib/libcurses.so

make clean
make
mv bam2prof "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/bam2prof"
cd ../..

# Ensure Python scripts are installed correctly
cp addeam-bam2prof.py addeam-cluster.py "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/addeam-bam2prof.py" "${PREFIX}/bin/addeam-cluster.py"

# Add ${PREFIX}/bin to PATH so tests can find the executables
export PATH="${PREFIX}/bin:$PATH"


