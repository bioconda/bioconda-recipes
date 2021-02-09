#!/bin/bash

mkdir -p ${PREFIX}/bin

if [ `uname` == Darwin ]; then
    echo "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm111111111111111111111111"
    brew install gcc
    HASHFLG=-Wno-deprecated
    BUILDFLG=-w -ffunction-sections -fdata-sections -fmodulo-sched -msse    
    EXE_TAL=bin/MS-single-to-table
    EXE_T2S=bin/MS-table-to-single
    EXE_CMP=bin/MS-comp-taxa
    EXE_CPD=bin/MS-comp-taxa-dynamic
    EXE_MMR=bin/MS-make-ref
    g++-10 -o $(EXE_TAL) src/taxa_sel.cpp $(HASHFLG) $(BUILDFLG) -fopenmp
    g++-10 -o $(EXE_T2S) src/table2single.cpp $(HASHFLG) $(BUILDFLG) -fopenmp
    g++-10 -o $(EXE_CMP) src/comp_sam.cpp $(HASHFLG) $(BUILDFLG) -fopenmp
    g++-10 -o $(EXE_CPD) src/comp_sam_dynamic.cpp $(HASHFLG) $(BUILDFLG) -fopenmp
    g++-10 -o $(EXE_MMR) src/make_ref.cpp $(HASHFLG) $(BUILDFLG) -fopenmp
else
    echo "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn2222222222222222222222222"
    make
fi

cp bin/* ${PREFIX}/bin
cp -r databases ${PREFIX}
