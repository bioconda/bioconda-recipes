#!/bin/sh

# useless default include directory that is silently added by the compiler packages "to help"...
# it is not even added with -isystem https://github.com/AnacondaRecipes/aggregate/blob/master/clang/activate-clang%2B%2B.sh#L87
USELESS="-I${PREFIX}/include"
export CXXFLAGS=${CXXFLAGS//${USELESS}/}

# Not sure if those are needed 
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
#export DYLD_LIBRARY_PATH=${PREFIX}/lib

mkdir build
cd build

if [[ $(uname -s) == Darwin ]]; then
  RPATH='@loader_path/../lib'
else
  ORIGIN='$ORIGIN'
  export ORIGIN
  RPATH='$${ORIGIN}/../lib'
fi
LDFLAGS='-Wl,-rpath,${RPATH}'

cmake ../src/pyOpenMS \
  -DOPENMS_GIT_SHORT_REFSPEC="release/${PKG_VERSION}" \
  -DOPENMS_GIT_SHORT_SHA1="b59e0c3" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${RPATH} \
  -DCMAKE_INSTALL_NAME_DIR="@rpath" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
  -DPython_EXECUTABLE=$PYTHON \
  -DPython_FIND_STRATEGY="LOCATION" \
  -DNO_DEPENDENCIES=ON

# NO_DEPENDENCIES since conda takes over re-linking etc

# limit parallel jobs to 1 for memory usage since pyopenms has huge cython generated cpp files
make -j1 pyopenms
$PYTHON -m pip install ./pyOpenMS/dist/*.whl --ignore-installed --no-deps
