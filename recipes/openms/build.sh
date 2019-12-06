#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

mkdir contrib-build
cd contrib-build
cmake -DBUILD_TYPE=WILDMAGIC ../contrib


mkdir -p $PREFIX/etc/conda/activate.d/ $PREFIX/etc/conda/deactivate.d/
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/openms.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/openms.sh

cd ..

# Use C++17 rather than C++11 to hopefully better match boost
sed -i.bak "s/11/17/g" CMakeLists.txt

mkdir build
cd build


## TODO is this really working also on macOS with frameworks?
ORIGIN='$ORIGIN'
export ORIGIN
LDFLAGS='-Wl,-rpath,$${ORIGIN}/../lib'

cmake .. 
  -DOPENMS_CONTRIB_LIBS='../../contrib-build' \
  -DCMAKE_INSTALL_PREFIX=$PREFIX -DHAS_XSERVER=OFF \
  -DENABLE_TUTORIALS=OFF \
  -DENABLE_STYLE_TESTING=OFF \
  -DENABLE_UNITYBUILD=OFF \
  -DWITH_GUI=OFF \
  -DBOOST_USE_STATIC=OFF \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DBoost_ARCHITECTURE="-x64"

make -j2 TOPP UTILS OpenMS
## TODO make install is not working well yet. We neither have installation 
## RPaths nor CMake exports that work correctly with installation.
make install
