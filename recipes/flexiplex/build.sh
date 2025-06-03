DIR=$PREFIX/bin
CFLAGS="-I$PREFIX/include -L$PREFIX/lib"

mkdir -p $DIR
make
make install DIR=$DIR
