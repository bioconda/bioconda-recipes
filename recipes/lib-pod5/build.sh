#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/include
mkdir -p ${PREFIX}/lib

cp -rf ${RECIPE_DIR}/POD5Version.cmake cmake/

${PYTHON} -m setuptools_scm

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_OSX_ARCHITECTURES=arm64"
fi

if [[ "${ARCH}" == "aarch64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
elif [[ "${ARCH}" == "arm64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
else
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$(pwd)" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DBUILD_PYTHON_WHEEL=ON \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"

if [[ "${OS}" == "Darwin" ]]; then
	${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --no-use-pep517 -vvv
	install -v lib/*.a "${PREFIX}/lib"
else
	${PYTHON} -m pip install *.whl --no-deps --no-build-isolation --no-cache-dir -vvv
	install -v lib64/*.a "${PREFIX}/lib"
fi

install -v include/pod5_format/*.h "${PREFIX}/include"
cp -rf include/pod5_format/svb16 "${PREFIX}/include"

cd python/lib_pod5/
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
