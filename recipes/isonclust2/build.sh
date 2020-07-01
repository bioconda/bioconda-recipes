#!/bin/bash
set -eoux pipefail

git clone --recursive https://github.com/nanoporetech/isonclust2

cd isonclust2
#git reset --hard v2.3
mkdir build
pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
echo $PKG_VERSION
make -j ${CPU_COUNT}

mkdir -p ${PREFIX}/bin
mv bin/isONclust2 ${PREFIX}/bin/
