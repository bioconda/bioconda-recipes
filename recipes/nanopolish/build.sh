#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Iminimap2 -I$PREFIX/include -std=c99"
export CXXFLAGS="${CXXFLAGS} -O3 -I$PREFIX/include"
export CPATH="${PREFIX}/include"

export HTS_LIB="${PREFIX}/lib/libhts.a"
export HTS_INCLUDE="-I${PREFIX}/include"
export FAST5_INCLUDE="-I${PREFIX}/include/fast5"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-O2|-O3|'  Makefile
rm -rf *.bak
sed -i.bak 's|CC     = gcc|CC     ?= $(CC)|'  htslib/Makefile
rm -rf htslib/*.bak

# Linker options aren't passed to minimap2
pushd minimap2
if [[ "${target_platform}" == "linux-aarch64" ]]; then
	wget https://github.com/jratcliff63367/sse2neon/archive/master.zip -O sse2neon-master.zip
	unzip sse2neon-master.zip
	mv ./sse2neon-master/SSE2NEON.h $PREFIX/include/sse2neon.h
	sed -i.bak 's|$(CFLAGS) -msse2|$(CFLAGS)|'  Makefile
	sed -i.bak 's|$(CFLAGS) -msse4.1|$(CFLAGS)|'  Makefile
	sed -i.bak 's|$(CFLAGS) -mno-sse4.1|$(CFLAGS)|'  Makefile
	rm -rf *.bak
	sed -i'' -e "9c #include <sse2neon.h>" ksw2_ll_sse.c
	sed -i'' -e "23c #elif defined(__i386__)// on 32bit, ebx can NOT be used as PIC code" ksw2_dispatch.c
	sed -i'' -e "26a #else " ksw2_dispatch.c
	sed -i'' -e "27a\\\        cpuid[0] = cpuid[1] = cpuid[2] = cpuid[3] = 0;" ksw2_dispatch.c
 	sed -i'' -e "55a #if defined(__x86_64__) || defined(__i386__)	" ksw2_dispatch.c
	sed -i'' -e "99a #endif" ksw2_dispatch.c

	sed -i'' -e '326s/^/\/\//'   align.c
	sed -i'' -e '329s/^/\/\//'   align.c
	sed -i'' -e '330s/^/\/\//'   align.c
	sed -i'' -e '331s/^/\/\//'   align.c
	sed -i'' -e '332s/^/\/\//'   align.c
	sed -i'' -e '333s/^/\/\//'   align.c
	sed -i'' -e '334s/^/\/\//'   align.c
elif [[ "${target_platform}" == "osx-arm64" ]]; then
	sed -i.bak 's|-msse2||'  Makefile
	sed -i.bak 's|-msse4.1||'  Makefile
	sed -i.bak 's|-mno-sse4.1||'  Makefile
fi

if [[ "${target_platform}" == "linux-aarch64" || "${target_platform}" == "osx-arm64" ]]; then
	make libminimap2.a arm_neon=1 CFLAGS="$CFLAGS -Wno-implicit-function-declaration" CXXFLAGS="$CXXFLAGS" LIBS="-L$PREFIX/lib -lm -lz -pthread" -j"${CPU_COUNT}"
else
	make libminimap2.a CFLAGS="$CFLAGS -Wno-implicit-function-declaration" CXXFLAGS="$CXXFLAGS" LIBS="-L$PREFIX/lib -lm -lz -pthread" -j"${CPU_COUNT}"
fi

popd

pushd slow5lib
sed -i.bak 's|CC			= cc|CC			?= $(CC)|' Makefile
sed -i.bak "s|gcc|${CC}|" Makefile
sed -i.bak 's|AR			= ar|#AR			= ar|' Makefile
rm -rf *.bak

make lib/libslow5.a CC="${CC}" -j"${CPU_COUNT}"
popd

make HDF5=noinstall EIGEN=noinstall HTS=noinstall MINIMAP=noinstall CXXFLAGS="${CXXFLAGS} -Iminimap2 -Islow5lib -fopenmp -g -O3"
install -v -m 0755 nanopolish $PREFIX/bin
cp -f scripts/nanopolish_makerange.py $PREFIX/bin
cp -f scripts/nanopolish_merge.py $PREFIX/bin
