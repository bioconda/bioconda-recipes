#!/bin/bash
set -x
set +e

sh autogen.sh

# PhyML builds different binaries depending on configure flags.
# We build
#   - phyml (enable-phyml),
#   - phyml-mpi (enable-mpi),
#   - phytime
# but not
#   - phyml-beagle -- doesn't compile in this relase
#   - phyrex -- doesn't build

for binary in beagle mpi phyml; do
    ./configure \
	--disable-dependency-tracking \
	--prefix $PREFIX \
	--disable-debug \
	--enable-$binary
    make -j$CPU_COUNT
    make check
    make install
    make clean
done


