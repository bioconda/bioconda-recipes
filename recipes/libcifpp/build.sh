mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --config Release
ctest -C Release
cmake --install . --prefix $PREFIX
