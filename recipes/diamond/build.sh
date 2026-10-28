#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-attributes -Wno-volatile -Wno-inconsistent-missing-override -Wno-deprecated-declarations -Wno-format -Wno-unknown-warning-option"
export CMAKE_C_COMPILER="${CC}"
export CMAKE_CXX_COMPILER="${CXX}"
export CMAKE_ARGS="-S src -B . -DCMAKE_BUILD_TYPE=Release -Wno-dev -Wno-deprecated --no-warn-unused-cli"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export CONFIG_ARGS="-DARM=ON -DX86=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET="11.0" -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	export CONFIG_ARGS="-DX86=ON -DCMAKE_OSX_DEPLOYMENT_TARGET="10.15" -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	export CONFIG_ARGS="-DAARCH64=ON -DX86=OFF"
else
	export CONFIG_ARGS="-DX86=ON"
fi

cd "${SRC_DIR}"

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DWITH_ZSTD=ON \
	-DZSTD_LIBRARY="${PREFIX}/lib/libzstd.a" -DZSTD_INCLUDE_DIR="${PREFIX}/include" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
