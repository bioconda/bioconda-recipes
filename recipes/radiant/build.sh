
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -S . -B build
cmake --build build
cmake install build

