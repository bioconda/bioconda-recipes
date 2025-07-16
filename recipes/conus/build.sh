#!/bin/bash

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CXXFLAGS} -fcommon"
./configure
make 

binaries="ambtest \
            conus_compare \
            conus_fold \
            conus_train \
            findopt \
            pocheck \
            reorder \
            scheck \
            stk2ct \
            weedamb \
            "
mkdir -p $PREFIX/bin
for i in $binaries; do cp src/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
