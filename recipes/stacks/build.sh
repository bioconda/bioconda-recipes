#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-unqualified-std-cast-call -Wno-c++11-narrowing-const-reference"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-unqualified-std-cast-call -Wno-c++11-narrowing-const-reference"

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

if [[ "$(uname -s)" == "Darwin" ]]; then
    # Fix for install_name_tool error:
    #   error: install_name_tool: changing install names or rpaths can't be
    #   redone for: $PREFIX/bin/abyss-overlap (for architecture x86_64) because
    #   larger updated load commands do not fit (the program must be relinked,
    #   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names -Wl,-dead_strip_dylibs -Wl,-rpath,${PREFIX}/lib"
fi

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* config/

./configure --prefix="$PREFIX" \
	--disable-option-checking \
	--enable-silent-rules \
	--disable-dependency-tracking \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install

# copy missing scripts
install -v -m 0755 scripts/*.pl "$PREFIX/bin"
