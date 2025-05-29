#!/bin/bash
set -x

export CXXFLAGS="${CXXFLAGS} -std=c++14"

if [ "$(uname)" = "Darwin" -a "$(uname -m)" = "x86_64" ]; then
    sed -i.bak "s#extern errno_t memset_s#//xxx extern errno_t memset_s#g" ext/safestringlib/include/safe_mem_lib.h
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/include/safe_mem_lib.h
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/memset16_s.c
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/memset32_s.c
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/memset_s.c
    sed -i.bak 's/memset_s/memset8_s/g' ext/safestringlib/safeclib/wmemset_s.c
 # for safestringlib to compile
    CFLAGS="${CFLAGS} -Wno-error=implicit-function-declaration"
fi


case "$(uname -m)" in
  x86_64)
      	LIBS="${LDFLAGS}" make -j${CPU_COUNT} CC="${CC}" CXX="${CXX}" multi ;;
  arm64|aarch64)      
        rm -rf ext/sse2neon
        git submodule add https://github.com/DLTcollab/sse2neon ext/sse2neon
        cd ext/sse2neon ; git checkout tags/v1.8.0
        cd ../..
	LIBS="${LDFLAGS}" make -j${CPU_COUNT} arch="-march=armv8-a" EXE=bwa-mem2 CC="${CC}" CXX="${CXX}" all
      ;;
  *)
      echo "Not supported architecture: $(uname -m)" ;;
esac

mkdir -p $PREFIX/bin
cp bwa-mem2* $PREFIX/bin
