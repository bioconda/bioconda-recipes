#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

# Set up Apegrunt; it's configured as a submodule to SpydrPick on GitHub, but since
# Bioconda doesn't recommend using git_url (and 'clone --recursive' that would also
# clone the submodule), we do it manually instead
rmdir externals/apegrunt
git clone --branch v0.5.0 https://github.com/santeripuranen/apegrunt.git externals/apegrunt

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

# build and install SpydrPick (but only the SpydrPick make target)
# export CMAKE_MODULE_PATH="${RECIPE_DIR}"
mkdir build && pushd build

cmake -S .. -B . -DCMAKE_BUILD_TYPE=Release \
	-DTBB_ROOT="${PREFIX}" -DBOOST_ROOT="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBoost_DEBUG=1 -DBoost_INCLUDEDIR="${PREFIX}/include" \
	-DBoost_LIBRARYDIR="${PREFIX}/lib" "${CONFIG_ARGS}"
cmake --build . --target SpydrPick -j "${CPU_COUNT}" -v

install -d ${PREFIX}/bin
install bin/SpydrPick ${PREFIX}/bin
popd
