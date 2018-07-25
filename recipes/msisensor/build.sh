export CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/bam"
export LD_LIBRARY_PATH=${PREFIX}/lib
make
cp msisensor $PREFIX/bin

