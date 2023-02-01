cmake -B build -DCMAKE_C_FLAGS="-msse4.2" -DCMAKE_CXX_FLAGS="-msse4.2" -DCMAKE_INSTALL_PREFIX=$PREFIX
make -C build
make -C build install
