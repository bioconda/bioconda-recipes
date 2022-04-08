cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DNOAVX=ON .
make hyphy HYPHYMPI
make install
