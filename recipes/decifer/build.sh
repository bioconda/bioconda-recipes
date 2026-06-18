#!/usr/bin/env bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

mkdir build
cd build

cmake -DLIBLEMON_ROOT=${PREFIX} \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}" \
	../src/decifer/cpp/

cmake --build . -j "${CPU_COUNT}"
install -v -m 0755 mergestatetrees generatestatetrees "$PREFIX/bin"

cd ..

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
