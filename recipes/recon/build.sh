#!/bin/sh
set -x -e

mkdir -p ${PREFIX}/bin

cd src/
make CC=$CC -j ${CPU_COUNT}
make install
cd ..
cp bin/* ${PREFIX}/bin

# add read permissions to LICENSE
chmod a+r LICENSE