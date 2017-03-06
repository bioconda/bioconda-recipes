mkdir build
cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=${PREFIX}/lemon \

make install
