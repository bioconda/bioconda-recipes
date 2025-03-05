#!/bin/bash
set -x

export CXXFLAGS="${CXXFLAGS} -std=c++14"
if [ "$(uname)" = "Darwin" ]; then
  # add ironic flag for safe library..
  export CC="${CC} -Wno-error=implicit-function-declaration"
fi

rm -rf ext/sse2neon
git submodule add https://github.com/DLTcollab/sse2neon ext/sse2neon
cd ext/sse2neon ; git checkout tags/v1.8.0
cd ../..

case "$(uname -m)" in
  x86_64)
      	LIBS="${LDFLAGS}" make -j${CPU_COUNT} CC="${CC}" CXX="${CXX}" multi ;;
  aarch64)      
	LIBS="${LDFLAGS}" make -j${CPU_COUNT} arch="-march=armv8-a" EXE=bwa-mem2 CC="${CC}" CXX="${CXX}" all
      ;;
  arm64) # has to be darwin
        LIBS="${LDFLAGS}" make -j${CPU_COUNT} arch="-march=armv8-a" EXE=bwa-mem2 CC="${CC}" CXX="${CXX}" all
      ;;
  *)
      echo "Not supported architecture: $(uname -m)" ;;
esac

mkdir -p $PREFIX/bin
cp bwa-mem2* $PREFIX/bin
