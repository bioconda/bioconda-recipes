#!/bin/bash

mkdir -p ${PREFIX}/bin

export DynamicMetaStorms=${PREFIX}

if [ `uname` == Darwin ]; then
    HASHFLG=-Wno-deprecated
    BUILDFLG=-w -ffunction-sections -fdata-sections -fmodulo-sched -msse    
    $(CXX) -o $(EXE_TAL) src/taxa_sel.cpp $(HASHFLG) $(BUILDFLG) -openmp=libomp
else
    make
fi

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
