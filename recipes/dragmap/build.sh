#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"
export BOOST_ROOT="${PREFIX}"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

sed -i.bak 's|-lpthread|-pthread|' config.mk
sed -i.bak 's|-O2|-O3|' config.mk
# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

case $(uname -s) in
    "Darwin")
	sed -i.bak 's|-fpredictive-commoning||g' config.mk
	sed -i.bak 's|-fipa-cp-clone||g' config.mk
	sed -i.bak 's|-ftree-phiprop||g' config.mk
	sed -i.bak 's|-lrt -lgomp|-lomp|' config.mk
	sed -i.bak 's|#include <queue>|\#include <algorithm>|' src/lib/align/Aligner.cpp
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -D_LIBCPP_DISABLE_AVAILABILITY"
	;;
esac

if [[ "$target_platform" == "linux-aarch64" || "$target_platform" == "osx-arm64" ]]; then
	sed -i'.bak' 's%-mavx2% %g' config.mk
	sed -i'.bak' 's%-msse4.2% %g' config.mk
	sed -i'.bak' 's/__m256i\*/void*/g' ./thirdparty/sswlib/ssw/ssw_internal.hpp
	sed -i'.bak' 's|#include "SSE2NEON.h"|#include "sse2neon.h"|' thirdparty/dragen/src/host/metrics/public/mapping_stats.hpp
	sed -i'.bak' 's|#include <xmmintrin.h>|#include "sse2neon.h"|' thirdparty/dragen/src/host/metrics/public/mapping_stats.hpp
	sed -i'.bak' 's|#define _TARGET_X86_|#define __ARM_NEON|' thirdparty/dragen/src/host/metrics/public/mapping_stats.hpp
	sed -i'.bak' 's|#elif defined(_TARGET_ARM_)|#elif defined(__ARM_NEON)|' thirdparty/dragen/src/host/metrics/public/mapping_stats.hpp
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h thirdparty/dragen/src/host/metrics/public/
	cp -f sse2neon/sse2neon.h thirdparty/sswlib/ssw/
	cp -f sse2neon/sse2neon.h src/include/align/
	cp -f sse2neon/sse2neon.h src/lib/align/
	cp -f sse2neon/sse2neon.h src/lib/sequences/
fi
rm -f *.bak

if [[ "$target_platform" == "linux-aarch64" ]]; then
	sed -i'.bak' '/CXXFLAGS +=/ s/$/ -march=armv8-a /' make/lib.mk
elif [[ "$target_platform" == "osx-arm64" ]]; then
	sed -i'.bak' '/CXXFLAGS +=/ s/$/ -march=armv8.4-a /' make/lib.mk
else
	sed -i'.bak' '/CXXFLAGS +=/ s/$/ -march=x86-64-v3 /' make/lib.mk
fi
rm -f make/*.bak

echo "pwd:----------------------------$PWD----------------"
HAS_GTEST=0 make CXX="${CXX}" CC="${CC}" CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" -j"${CPU_COUNT}"

install -v -m 0755 build/release/dragen-os "${PREFIX}/bin"

"${STRIP}" "${PREFIX}/bin/dragen-os"
