#!/bin/bash


mkdir -p $PREFIX/bin
workdir=$PWD

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

pushd abPOA 
make libabpoa PREFIX=$workdir CFLAGS="${CFLAGS} -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I$PREFIX/include"
popd

make CFLAGS="${CFLAGS} -I${PREFIX}/include" LIB_PATH="-L${PREFIX}/lib"
