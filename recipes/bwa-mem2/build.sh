#!/bin/bash
set -x

export CXXFLAGS="${CXXFLAGS} -std=c++14"
if [ "$(uname)" = "Darwin" -a "$(uname -m)" = "x86_64" ]; then
  # add ironic flag for safe library..
  export CC="${CC} -Wno-error=implicit-function-declaration"
  # makefile isn't propagating at all well..
  sed -i 's/directories libsafestring.a/CFLAGS="-Iinclude -fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Wno-error=implicit-function-declaration" directories libsafestring.a/g' Makefile
  make ext/safestringlib/libsafestring.a
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
