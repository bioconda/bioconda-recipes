#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="$CFLAGS -I$PREFIX/include -g -Wall"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lz -lm"

export CPATH=${PREFIX}/include

cd ./VGP
sed -i.bak 's/CC     = gcc//g' HTSLIB/Makefile
sed -i.bak 's/CPPFLAGS =//g' HTSLIB/Makefile
# sed -i.bak 's/libhts.a: HTSLIB//g' Makefile
# sed -i.bak 's/libhts.a//g' Makefile

sed -i.bak 's/cd HTSLIB; make; cd ..//g' Makefile
sed -i.bak 's/gcc/${CC}/g' Makefile
cat Makefile
cd HTSLIB
COMPILER=${CC} make prefix=${PREFIX} CC=${CC} AR=${AR} RANLIB=${RANLIB} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
cd ..
COMPILER=${CC} make prefix=${PREFIX} CC=${CC} AR=${AR} RANLIB=${RANLIB} CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make install

mkdir -p ${PREFIX}/bin

cp ./VGPzip ${PREFIX}/bin/VGPzip
cp ./VGPseq ${PREFIX}/bin/VGPseq
cp ./VGPpair ${PREFIX}/bin/VGPpair
cp ./VGPpacbio ${PREFIX}/bin/VGPpacbio
cp ./VGPcloud ${PREFIX}/bin/VGPcloud
cp ./Dazz2pbr ${PREFIX}/bin/Dazz2pbr
cp ./Dazz2sxs ${PREFIX}/bin/Dazz2sxs

chmod +x ${PREFIX}/bin/VGPzip
chmod +x ${PREFIX}/bin/VGPseq
chmod +x ${PREFIX}/bin/VGPpair
chmod +x ${PREFIX}/bin/VGPpacbio
chmod +x ${PREFIX}/bin/VGPcloud
chmod +x ${PREFIX}/bin/Dazz2pbr
chmod +x ${PREFIX}/bin/Dazz2sxs
