#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
	aarch64|arm64) sed -i.bak 's|-march=x86-64|-march=armv8-a|' CMakeLists.txt && rm -rf *.bak ;;
	arm64) sed -i.bak 's|-march=x86-64|-march=armv8.4-a|' CMakeLists.txt && rm -rf *.bak ;;
	x86_64) sed -i.bak 's|-march=x86-64|-march=x86-64-v3|' CMakeLists.txt && rm -rf *.bak ;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated \
	--no-warn-unused-cli "${CONFIG_ARGS}"

ninja -C build -j "${CPU_COUNT}"

install -v -m 0755 build/aliceasm build/graphunzip build/reduce "${PREFIX}/bin"
install -v -m 0755 bcalm/scripts/convertToGFA.py "${PREFIX}/bin"
