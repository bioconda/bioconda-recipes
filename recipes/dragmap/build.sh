#!/bin/bash


export HAS_GTEST=0

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

# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

if [[ "$target_platform" == "linux-aarch64" || "$target_platform" == "osx-arm64" ]]; then
	sed -i.bak 's%-mavx2% %g' config.mk
        sed -i.bak 's%-msse4.2% %g' config.mk
        sed -i'.bak' 's/__m256i\*/void*/g' ./thirdparty/sswlib/ssw/ssw_internal.hpp
	git clone https://github.com/DLTcollab/sse2neon.git
	cp -f sse2neon/sse2neon.h ./thirdparty/dragen/src/host/metrics/public
	cp -f sse2neon/sse2neon.h ./thirdparty/sswlib/ssw
	cp -f sse2neon/sse2neon.h ./src/include/align
	cp -f sse2neon/sse2neon.h ./src/lib/align
	cp -f sse2neon/sse2neon.h ./src/lib/sequences
fi

if [[ "$target_platform" == "linux-aarch64" ]]; then
	sed -i'.bak' '/CXXFLAGS +=/ s/$/ -march=armv8-a /' ./make/lib.mk
elif [[ "$target_platform" == "osx-arm64" ]]; then
	sed -i'.bak' '/CXXFLAGS +=/ s/$/ -march=armv8.4-a /' ./make/lib.mk
fi

echo "pwd:----------------------------$PWD----------------"
make CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"
else
make CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS"
fi

install -v -m 0755 build/release/dragen-os ${PREFIX}/bin
