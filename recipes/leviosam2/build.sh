mkdir -p build;
cd build;
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ${SRC_DIR}
make;
make install
