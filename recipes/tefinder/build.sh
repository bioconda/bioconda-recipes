mkdir -p build
cd build
cmake ../
make install
cp ../bin/* ${PREFIX}/bin

