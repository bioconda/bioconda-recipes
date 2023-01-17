mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DENABLE_AVX=OFF
make
make install
