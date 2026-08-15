#!/bin/bash

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

if [[ "${target_platform}" == "linux-aarch64" || "${target_platform}" == "osx-arm64" ]]; then

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}" gustaf
ninja -C build -j "${CPU_COUNT}" gustaf_mate_joining

install build/bin/gustaf* "$PREFIX/bin"

else

cd bin

binaries="\
gustaf \
gustaf_mate_joining \
"

for i in $binaries; do install -v -m 0755 $SRC_DIR/bin/$i $PREFIX/bin; done

fi
