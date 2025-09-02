#!/bin/bash
export CFLAGS="-Iminimap2 -I$PREFIX/include -std=c99"
export CPATH=${PREFIX}/include

export HTS_LIB=${PREFIX}/lib/libhts.a
export HTS_INCLUDE=-I${PREFIX}/include
export FAST5_INCLUDE=-I${PREFIX}/include/fast5

mkdir -p $PREFIX/bin

# Linker options aren't passed to minimap2
pushd minimap2
if [[ ${target_platform}  == "linux-aarch64" ]]; then
	wget https://github.com/jratcliff63367/sse2neon/archive/master.zip -O sse2neon-master.zip
	unzip sse2neon-master.zip
	mv ./sse2neon-master/SSE2NEON.h $PREFIX/include/sse2neon.h
	sed -i.bak 's|$(CFLAGS) -msse2|$(CFLAGS)|'  Makefile
	sed -i.bak 's|$(CFLAGS) -msse4.1|$(CFLAGS)|'  Makefile
	sed -i.bak 's|$(CFLAGS) -mno-sse4.1|$(CFLAGS)|'  Makefile
	rm -rf *.bak
	sed -i "9c #include <sse2neon.h>" ksw2_ll_sse.c
	sed -i "23c #elif defined(__i386__)// on 32bit, ebx can NOT be used as PIC code" ksw2_dispatch.c
	sed -i "26a #else " ksw2_dispatch.c
	sed -i "27a\\\        cpuid[0] = cpuid[1] = cpuid[2] = cpuid[3] = 0;" ksw2_dispatch.c
 	sed -i "55a #if defined(__x86_64__) || defined(__i386__)	" ksw2_dispatch.c
	sed -i "99a #endif" ksw2_dispatch.c

	sed -i '326s/^/\/\//'   align.c
	sed -i '329s/^/\/\//'   align.c
	sed -i '330s/^/\/\//'   align.c
	sed -i '331s/^/\/\//'   align.c
	sed -i '332s/^/\/\//'   align.c
	sed -i '333s/^/\/\//'   align.c
	sed -i '334s/^/\/\//'   align.c
fi

make CFLAGS="$CFLAGS -Wno-implicit-function-declaration " CXXFLAGS="$CXXFLAGS" LIBS="-L$PREFIX/lib -lm -lz -pthread" libminimap2.a
popd

pushd slow5lib
make CC=$CC lib/libslow5.a
popd

make HDF5=noinstall EIGEN=noinstall HTS=noinstall MINIMAP=noinstall CXXFLAGS="$CXXFLAGS -Iminimap2 -Islow5lib -fopenmp -g -O3 "
cp nanopolish $PREFIX/bin
cp scripts/nanopolish_makerange.py $PREFIX/bin
cp scripts/nanopolish_merge.py $PREFIX/bin
# cp scripts/consensus-preprocess.pl $PREFIX/bin # Skipping this pre-processing step at the moment.
