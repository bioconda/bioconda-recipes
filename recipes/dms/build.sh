#!/bin/bash

mkdir -p ${PREFIX}/bin

OMPFLG=-fopenmp
HASHFLG=-Wno-deprecated
BUILDFLG=-w -ffunction-sections -fdata-sections -fmodulo-sched -msse
EXE_TAL=${PREFIX}/bin/MS-single-to-table
EXE_T2S=${PREFIX}/bin/MS-table-to-single
EXE_CMP=${PREFIX}/bin/MS-comp-taxa
EXE_CPD=${PREFIX}/bin/MS-comp-taxa-dynamic
EXE_MMR=${PREFIX}/bin/MS-make-ref
tax:
	$(cxx) -o $(EXE_TAL) src/taxa_sel.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
	$(cxx) -o $(EXE_T2S) src/table2single.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
	$(cxx) -o $(EXE_CMP) src/comp_sam.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
	$(cxx) -o $(EXE_CPD) src/comp_sam_dynamic.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
	$(cxx) -o $(EXE_MMR) src/make_ref.cpp $(HASHFLG) $(BUILDFLG) $(OMPFLG)
clean:
	rm -rf bin/* src/*.o 