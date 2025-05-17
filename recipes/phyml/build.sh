#!/bin/bash
set -xe

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer -funroll-loops -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LC_ALL="en_US.UTF-8"

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

# needed to fix version
autoreconf -if

# Adding -v to make breaks compilation on Microsoft Azure CI
# phyml-mpi error: mpi_boot.c:215:100: error: 'struct __Optimiz' has no member named 'opt_bl'
for binary in phyml phytime rf; do
	echo ${binary}
	./configure \
		--disable-dependency-tracking \
		--enable-silent-rules \
		--prefix="${PREFIX}" \
		--enable-${binary} \
		CC="${CC}" CPPFLAGS="${CPPFLAGS}" \
		LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} ${ARCH_OPTS}"
	make CFLAGS="${CFLAGS} ${ARCH_OPTS}" -j"${CPU_COUNT}"
	make install
	make clean
done
