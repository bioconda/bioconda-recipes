export CXXFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DNOAVX=ON .
make hyphy HYPHYMPI
make install
