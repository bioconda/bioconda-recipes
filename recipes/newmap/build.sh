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
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first -j "${CPU_COUNT}"

cd ..

# Do not install dependencies, instead use the conda environment
${PYTHON} -m pip install --disable-pip-version-check --no-deps --no-cache-dir --no-build-isolation -vvv

# Work around for no 'source_files' support in test section of meta.yaml
cp test/run_tests.py $PREFIX/bin/run_genomedata_tests.py
cp test/test_genomedata.py $PREFIX/bin
cp -r test/data $PREFIX/bin
