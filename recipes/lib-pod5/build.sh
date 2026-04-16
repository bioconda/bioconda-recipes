#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations -Wno-implicit-function-declaration -Wno-array-bounds"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations -Wno-array-bounds"

mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib
# fixes: file COPY_FILE failed to copy
# /opt/conda/conda-bld/lib-pod5_1776303586892/work/LICENSE.md
mkdir -p python/lib_pod5/licenses

${PYTHON} -m setuptools_scm
${PYTHON} -m pod5_make_version

OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "${ARCH}" == "aarch64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${ARCH}" == "arm64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

if [[ "${OS}" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_OSX_ARCHITECTURES=arm64"
fi

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DBUILD_PYTHON_WHEEL=ON \
	-DPython_EXECUTABLE="${PYTHON}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build install -j "${CPU_COUNT}"

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
