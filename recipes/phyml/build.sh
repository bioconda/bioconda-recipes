#!/bin/bash
set -xe

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer -funroll-loops"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

# needed to fix version
autoreconf -if

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
		LDFLAGS="${LDFLAGS}"
	make CC="${CC}" CFLAGS="${CFLAGS} ${ARCH_OPTS}" -j"${CPU_COUNT}"
	make install
	make clean
done
