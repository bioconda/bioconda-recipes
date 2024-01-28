mkdir -p $PREFIX/bin

mkdir build
cd build/
cmake ..
make

cp -r ./QuickDeconvolution $PREFIX/bin
