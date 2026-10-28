#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

# use newer config.guess and config.sub that support osx-arm64
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .

mv configure.in configure.ac

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export EXTRA_ARGS="--host=arm64"
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export EXTRA_ARGS="--host=aarch64"
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
else
	export EXTRA_ARGS="--host=x86_64"
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

# Regenerate configure to fix flat namespace errors on macOS 11+
autoreconf -if
./configure --prefix="${PREFIX}" \
	--without-x \
	--with-thread \
	--disable-option-checking \
	--disable-dependency-tracking \
	--enable-silent-rules \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	"${EXTRA_ARGS}"

make -j"${CPU_COUNT}"
make install

chmod +rx $RECIPE_DIR/fix_acd_path.py
${PYTHON} $RECIPE_DIR/fix_acd_path.py "$PREFIX/bin"
