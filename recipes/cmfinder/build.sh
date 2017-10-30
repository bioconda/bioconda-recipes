mkdir -p $PREFIX/bin
./configure --disable-debugging 
make 
cp bin/* $PREFIX/bin/ 
