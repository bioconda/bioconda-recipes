export JELLYFISH2_0_CFLAGS=-I$PREFIX/include/jellyfish-2.2.6/
export JELLYFISH2_0_LIBS=$PREFIX/lib/libjellyfish-2.0.dylib

./configure --prefix=$PREFIX
make
make install
