#!/bin/bash
set -ex

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"

cmake -S . -B build -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}"

"${STRIP}" build/src/minnow
"${STRIP}" build/src/constructgraph
"${STRIP}" build/src/validate

install -v -m 0755 build/src/minnow "$PREFIX/bin"
install -v -m 0755 build/src/constructgraph "$PREFIX/bin"
install -v -m 0755 build/src/validate "$PREFIX/bin"

cp -f build/src/libgraphlib.a "$PREFIX/lib"
cp -f build/src/libminnowlib.a "$PREFIX/lib"
cp -f build/src/libvalidatelib.a "$PREFIX/lib"
