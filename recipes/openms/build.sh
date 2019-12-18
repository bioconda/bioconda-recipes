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

mkdir build
cd build


## TODO is this really working also on macOS with frameworks?
ORIGIN='$ORIGIN'
export ORIGIN
LDFLAGS='-Wl,-rpath,$${ORIGIN}/../lib'

cmake .. \
  -DOPENMS_CONTRIB_LIBS='../../contrib-build' \
  -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DWITH_GUI=OFF \
  -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DBoost_ARCHITECTURE="-x64" \
  -DBUILD_EXAMPLES=OFF \
  -DPYOPENMS=ON

make -j${CPU_COUNT} OpenMS TOPP UTILS pyopenms
make install
