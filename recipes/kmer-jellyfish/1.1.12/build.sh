#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -fsigned-char -std=c++14"
export CFLAGS="${CFLAGS} -O3 -fsigned-char"

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

case "$(uname -s)" in
    Darwin)
	export MD5="md5 -r";;
    Linux)
	export MD5="md5sum";;
    *)
	echo "Not supported";;
esac

case "$(uname -m)" in
    "x86_64")
        export EXTRA_ARGS="--with-sse";;
    *)
	export EXTRA_ARGS="--without-see";;
esac

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -fi
./configure --prefix="$PREFIX" \
	"${EXTRA_ARGS}" \
	--disable-option-checking \
	--enable-silent-rules \
	--disable-dependency-tracking \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
