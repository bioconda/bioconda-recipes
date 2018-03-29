export ROOT=$PREFIX
mkdir -p $PREFIX/usr/include
./configure --prefix=$PREFIX/ --build=$PREFIX/share/ncbi
make -C ngs-sdk
make -C ngs-sdk install
make -C ngs-sdk test
