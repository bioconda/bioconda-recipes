
set -e
set -x

mkdir -p build
cd build

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_TESTS=ON \
  ${SRC_DIR}

#make -j${CPU_COUNT} savvy
make -j${CPU_COUNT} sav
make -j${CPU_COUNT} savvy-test
make install
make test
cd ..
