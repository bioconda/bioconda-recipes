#!/bin/bash
set -e  # Exit on error

# Ensure headers from the conda environment are found
export CPATH="${PREFIX}/include"

# Pass the conda library directory to the linker
export LDFLAGS="-L${PREFIX}/lib"
#-L${SRC_DIR}/submodules/lib/htslib -L${SRC_DIR}/submodules/lib/samtools -L${SRC_DIR}/submodules/lib/libgab"
#export LDFLAGS="-Wl,-t -L${PREFIX}/lib -L${SRC_DIR}/submodules/lib/htslib -L${SRC_DIR}/submodules/lib/samtools -L${SRC_DIR}/submodules/lib/libgab"

# Adjust include directories to match your directory structure
export CFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"
export CPPFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"
export CXXFLAGS="-I${SRC_DIR}/submodules/lib/htslib -I${SRC_DIR}/submodules/lib/samtools -I${SRC_DIR}/submodules/lib/libgab -I${PREFIX}/include"

# Make sure binaries and scripts are installed in Conda's bin directory
mkdir -p "${PREFIX}/bin"

# Move into the source directory and compile C++ binary
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


