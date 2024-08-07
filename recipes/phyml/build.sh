#!/bin/bash
set -xe

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

case $(uname -m) in
	x86_64)
		ARCH_OPTS="-msse4.1"
		;;
	*)
		ARCH_OPTS=""
		;;
esac

# Adding -v to make breaks compilation on Microsoft Azure CI
for binary in phyml-mpi phyml phytime; do
	echo ${binary}
	./configure \
		--disable-dependency-tracking \
		--prefix="${PREFIX}" \
		--enable-${binary} \
		LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
	make -j"${CPU_COUNT}" CFLAGS="${CFLAGS} ${ARCH_OPTS}"
	make install
	make clean
done
