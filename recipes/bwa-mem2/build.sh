#!/bin/bash

# https://github.com/intel/safestringlib/issues/14
if [[ $OSTYPE == "darwin"* ]]; then
    sed -i.bak "s#extern errno_t memset_s#//xxx extern errno_t memset_s#g" ext/safestringlib/include/safe_mem_lib.h
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/include/safe_mem_lib.h
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/memset16_s.c
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/memset32_s.c
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/memset_s.c
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/wmemset_s.c
fi
LIBS="${LDFLAGS}" make CC="${CC}" CXX="${CXX}" multi

mkdir -p $PREFIX/bin
cp bwa-mem2* $PREFIX/bin
