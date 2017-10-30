mkdir -p $PREFIX/bin
./configure
make -Wno-return-type
cp bin/* $PREFIX/bin/ 
