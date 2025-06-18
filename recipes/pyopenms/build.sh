#!/bin/bash

# Not sure if those are needed 
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export LC_ALL="en_US.UTF-8"

#2to3 -w ${SP_DIR}/autowrap/*.py

if [[ $(uname -s) == "Darwin" ]]; then
  RPATH='@loader_path/../lib'
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DCMAKE_MACOSX_RPATH=ON -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${RPATH}"
else
  ORIGIN='$ORIGIN'
  export ORIGIN
  RPATH='$${ORIGIN}/../lib'
  export CONFIG_ARGS=""
fi

mkdir build
cd build

cmake -S ../ -B . -G Ninja -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="27e3601" -DOPENMS_CONTRIB_LIBS="$SRC_DIR/contrib-build" -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_PREFIX_PATH="${PREFIX}" -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_RPATH="${RPATH}" -DCMAKE_INSTALL_NAME_DIR="@rpath" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
  -DHAS_XSERVER=OFF -DENABLE_TUTORIALS=OFF -DWITH_GUI=OFF -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON -DBoost_ARCHITECTURE="-x64" -DBUILD_EXAMPLES=OFF \
  -DPython_EXECUTABLE="${PYTHON}" -DPython_FIND_STRATEGY="LOCATION" -DPY_NUM_MODULES=20 \
  -DNO_DEPENDENCIES=ON -DNO_SHARE=ON -DPYOPENMS=ON -DQT_HOST_PATH="${BUILD_PREFIX}" -DQT_HOST_PATH_CMAKE_DIR="${PREFIX}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"

# NO_DEPENDENCIES since conda takes over re-linking etc

# limit parallel jobs to 1 for memory usage since pyopenms has huge cython generated cpp files
#cmake --build . --clean-first --target pyopenms -j 1
ninja pyopenms -j"${CPU_COUNT}"

echo "wheels are in `find . | grep whl`"  >&2
${PYTHON} -m pip install ./pyOpenMS/dist/*.whl --no-build-isolation --no-deps --no-cache-dir --use-pep517 --no-binary=pyopenms -vvv
