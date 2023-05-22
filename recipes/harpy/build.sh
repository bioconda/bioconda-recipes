#! /usr/bin/env bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

# create conda PATH, if not already existing
mkdir -p $CONDA_PREFIX/bin

# build and install ema
rm -r ema
git clone --recursive https://github.com/EdHarry/ema.git
cd ema
git checkout haplotag
git submodule update --remote
git apply ../misc/makefile.patch
git apply ../misc/remove_native.patch
make CC="$CC -fcommon" CXX="$CXX -fcommon" LDFLAGS="$LDFLAGS"
chmod +x ema
cp ema $CONDA_PREFIX/bin/ema-h
cd ..

# Harpy executable
chmod +x harpy
cp harpy $CONDA_PREFIX/bin/

# rules
cp rules/*.smk $CONDA_PREFIX/bin/

# associated scripts
chmod +x utilities/*.{py,R,pl}
cp utilities/*.{py,R,pl} $CONDA_PREFIX/bin/

# reports
chmod +x reports/*.Rmd
cp reports/*.Rmd $CONDA_PREFIX/bin/