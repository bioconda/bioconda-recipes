#!/bin/sh

export F77="${FC}"
export CPP="${CXX}"
export CC="${CC}"

echo $F77
echo $CPP
echo $CC
echo ${GFORTRAN}

git clone https://github.com/SurajGupta/r-source
cd r-source
chmod 755 configure
./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3

cd src/nmath/standalone/
make CC="${CC}" CFLAGS="$CFLAGS" CXX={$CXX}  
cp rmathlib/* $HOME/.nimble/lib/

cd ../../../../
rm r-source

nimble --localdeps build -y --verbose -d:release
mkdir -p "${PREFIX}/bin"
cp sscocaller "${PREFIX}/bin/"
