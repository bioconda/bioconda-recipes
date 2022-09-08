mkdir build
cd build
cmake .. -DGUI=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
#cmake --install . --prefix $PREFIX