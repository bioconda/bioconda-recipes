#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

# use newer config.guess and config.sub that support osx-arm64
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* autotools/

# build version with MPI & Beagle
./configure --prefix="$PREFIX" \
    --with-readline --with-mpi --with-beagle="$PREFIX" \
    CC="$CC" CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" CPPFLAGS="$CPPFLAGS" \
    --disable-debug --disable-option-checking --enable-silent-rules --disable-dependency-tracking

make -j"$CPU_COUNT"
make install
make clean

mv $PREFIX/bin/mb{,-mpi}

# build version with Beagle only
./configure --prefix="$PREFIX" \
    --with-readline --with-beagle="$PREFIX" \
    CC="$CC" CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" CPPFLAGS="$CPPFLAGS" \
    --disable-debug --disable-option-checking --enable-silent-rules --disable-dependency-tracking

make -j"$CPU_COUNT"
make install
