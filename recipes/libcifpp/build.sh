mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --config Release -DCMAKE_INSTALL_PREFIX=$PREFIX
ctest -C Release
cmake --install . --prefix $PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX
