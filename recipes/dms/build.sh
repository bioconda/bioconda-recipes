#!/bin/bash

mkdir -p ${PREFIV}/bin
make 
CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" 
OMPFLG=-fopenmp
HASHFLG=-Wno-deprecated
BUILDFLG=-w -ffunction-sections -fdata-sections -fmodulo-sched -msse
EXE_TAL=${PREFIV}/bin/MS-single-to-table
EXE_T2S=${PREFIV}/bin/MS-table-to-single
EXE_CMP=${PREFIV}/bin/MS-comp-taxa
EXE_CPD=${PREFIV}/bin/MS-comp-taxa-dynamic
EXE_MMR=${PREFIV}/bin/MS-make-ref
$(CXX) -o $(EXE_TAL) src/taxa_sel.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
$(CXX) -o $(EXE_T2S) src/table2single.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
$(CXX) -o $(EXE_CMP) src/comp_sam.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
$(CXX) -o $(EXE_CPD) src/comp_sam_dynamic.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
$(CXX) -o $(EXE_MMR) src/make_ref.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)


