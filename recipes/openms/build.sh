#!/bin/sh

# useless default include directory that is silently added by the compiler packages "to help"...
# it is not even added with -isystem https://github.com/AnacondaRecipes/aggregate/blob/master/clang/activate-clang%2B%2B.sh#L87
USELESS="-I${PREFIX}/include"
export CXXFLAGS=${CXXFLAGS//${USELESS}/}

# Not sure if those are needed 
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
#export DYLD_LIBRARY_PATH=${PREFIX}/lib

mkdir contrib-build
cd contrib-build
## By default WM is built and linked statically such that it does not
## introduce a dependency that needs to be exported
cmake -DBUILD_TYPE=WILDMAGIC ../contrib
cd ..

# Use C++17 rather than C++11 to hopefully better match boost
sed -i.bak "s/11/17/g" CMakeLists.txt
sed -i.bak "s/CMAKE_MACOSX_RPATH FALSE/CMAKE_MACOSX_RPATH TRUE/g" CMakeLists.txt
sed -i.bak "s/CMAKE_INSTALL_NAME_DIR/FOO/g" CMakeLists.txt


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

cmake .. \
  -DOPENMS_CONTRIB_LIBS='../../contrib-build' \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${RPATH} \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DWITH_GUI=OFF \
  -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DBoost_ARCHITECTURE="-x64" \
  -DBUILD_EXAMPLES=OFF \
  -DPYOPENMS=ON

make -j${CPU_COUNT} OpenMS TOPP UTILS pyopenms
# The subpackages will do that (unfortunately "make install" installs everything right away)
# Another option would be to install somewhere into the build dir (to use the existent install commands)
# and then copy the relevant parts to the prefix. See CMAKE_INSTALL_PREFIX.
#make install
