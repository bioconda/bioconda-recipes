#!/bin/bash
set -e

# Build the IQ-TREE static library
echo "Building IQ-TREE static library..."
cd iqtree2
rm -rf build
mkdir build
cd build

cmake -DBUILD_LIB=ON -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make -j$(nproc)

# Move the built library to the expected location
cd ../..
mkdir -p src/piqtree/_libiqtree
mv iqtree2/build/libiqtree2.a src/piqtree/_libiqtree/

# Build and install the Python package
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
