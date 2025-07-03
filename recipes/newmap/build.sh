#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak 's|VERSION 2.4.4|VERSION 3.5|' AvxWindowFmIndex/lib/libdivsufsort/CMakeLists.txt
rm -rf AvxWindowFmIndex/lib/libdivsufsort/*.bak

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# Build AvxWindowFmIndex libraries
cd AvxWindowFmIndex

# Release build
cmake -S . -B . -DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build . --clean-first

cd ..

# Do not install dependencies, instead use the conda environment
${PYTHON} -m pip install --disable-pip-version-check --no-deps --no-cache-dir --no-build-isolation -vvv
