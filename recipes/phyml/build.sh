#!/bin/bash
set -x
set +e

# needed to fix version
sed -i.bak "s/20190321/20190908/" configure.ac
sh autogen.sh

# PhyML builds different binaries depending on configure flags.
# We build
#   - phyml (enable-phyml),
#   - phyml-mpi (enable-mpi),
#   - phytime
# but not
#   - phyml-beagle -- doesn't compile in this relase
#   - phyrex -- crashes with segfault

CFLAGS="$CFLAGS -std=c99 -O3 -fomit-frame-pointer -funroll-loops"

for binary in mpi phyml phyrex phytime; do
    ./configure \
	--disable-dependency-tracking \
	--prefix $PREFIX \
	--enable-$binary
    make -j$CPU_COUNT CFLAGS="$CFLAGS"
    make check
    make install
    make clean
done


