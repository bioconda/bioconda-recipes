mkdir -p build;
cd build;
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_LIBRARY_PATH=${PREFIX}/lib \
  -DCMAKE_INCLUDE_PATH=${PREFIX}/include \
  ${SRC_DIR}
make;
make install
