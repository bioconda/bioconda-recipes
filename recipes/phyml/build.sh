#!/bin/bash
set -x
set +e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer -funroll-loops"

# needed to fix version
sh ./autogen.sh
autoupdate

# PhyML builds different binaries depending on configure flags.
# We build
#   - phyml (enable-phyml),
#   - phyml-mpi (enable-phyml-mpi)
#   - phytime
# but not
#   - phyml-beagle -- doesn't compile in this release
#   - phyrex -- crashes with segfault

# Adding -v to make breaks compilation on Microsoft Azure CI
for binary in phyml-mpi phyml phytime; do
	echo ${binary}
	./configure \
		--disable-dependency-tracking \
		--prefix="${PREFIX}" \
		--enable-${binary} \
		LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
	make -j"${CPU_COUNT}" CFLAGS="${CFLAGS} -msse4.1"
	make install
	make clean
done
