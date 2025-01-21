#!/bin/bash
set -e
set -x

# Print patch contents
echo "Patch contents:"
cat external_project_fmt.patch

# Attempt to apply patch manually
patch -p1 < external_project_fmt.patch

mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

cmake .. -DCONDA_BUILD=ON
make -j${CPU_COUNT}
cd ..

cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin