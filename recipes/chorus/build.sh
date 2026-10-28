mkdir build
cd build
cmake ..
make -j
mkdir -p $PREFIX/bin
cp query $PREFIX/bin
cp createDB $PREFIX/bin