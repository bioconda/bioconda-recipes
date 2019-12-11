#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

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
  -DCMAKE_INSTALL_PREFIX=$PREFIX -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DWITH_GUI=OFF \
  -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DBoost_ARCHITECTURE="-x64" \
  -DPYOPENMS=ON \
  -DPY_NUM_THREADS=2

make -j${CPU_COUNT} OpenMS TOPP UTILS pyopenms
make install
