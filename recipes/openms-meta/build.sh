#!/bin/bash

# Not sure if those are needed
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

mkdir build
cd build

if [[ $(uname -s) == "Darwin" ]]; then
	RPATH="@loader_path/../lib"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DCMAKE_MACOSX_RPATH=ON -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -headerpad_max_install_names"
else
	ORIGIN="$ORIGIN"
	export ORIGIN
	RPATH="$${ORIGIN}/../lib"
	export CONFIG_ARGS=""
fi

cmake -S .. -B . -G Ninja -DCMAKE_BUILD_TYPE="Release" \
	-DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
	-DOPENMS_GIT_SHORT_SHA1="27e3601" -DOPENMS_CONTRIB_LIBS="$SRC_DIR/contrib-build" \
	-DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_INSTALL_RPATH="${RPATH}" -DCMAKE_INSTALL_NAME_DIR="@rpath" \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
	-DHAS_XSERVER=OFF -DENABLE_TUTORIALS=OFF -DWITH_GUI=OFF -DBOOST_USE_STATIC=OFF \
	-DBoost_NO_BOOST_CMAKE=ON -DBoost_ARCHITECTURE="-x64" -DQT_HOST_PATH="${BUILD_PREFIX}" -DQT_HOST_PATH_CMAKE_DIR="${PREFIX}" \
	-DBUILD_EXAMPLES=OFF -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

# limit concurrent build jobs due to memory usage on CI
#make OpenMS TOPP -j1
ninja -j"${CPU_COUNT}"
#cmake --build . --clean-first --target OpenMS -j 1
#cmake --build . --clean-first --target TOPP -j 1
# The subpackages will do the installing of the parts
#make install
