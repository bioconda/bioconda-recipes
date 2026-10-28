#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include -Wno-maybe-uninitialized -Wno-unused-result"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-maybe-uninitialized -Wno-unused-result -Wno-register"

mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

sed -i.bak -E 's/(inline void __ks_insertsort_)/static \1/g' src/samtools-0.1.18/ksort.h
rm -f src/samtools-0.1.18/*.bak

autoreconf -if
case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	export ARCH="-march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	export ARCH="-march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	export ARCH="-march=x86-64-v3"
	;;
esac

./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	--with-boost="${PREFIX}" \
	--with-boost-libdir="${PREFIX}/lib" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CXX="${CXX} ${ARCH} -std=c++14" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"

patch -p1 < ${RECIPE_DIR}/0003-tophat.patch
2to3 -w src/generate_chromosome.py src/bed_to_juncs src/contig_to_chr_coords src/sra_to_solid src/tophat-fusion-post
rm -f src/*.bak

make install
install -v -m 0755 src/generate_chromosome.py src/bed_to_juncs src/contig_to_chr_coords src/sra_to_solid src/tophat-fusion-post "${PREFIX}/bin"
