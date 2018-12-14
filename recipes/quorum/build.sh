export JELLYFISH2_0_CFLAGS=-I$PREFIX/include/jellyfish-2.2.6/
if [ "$(uname)" == "Darwin" ]; then
    echo "Use *.dylib for OSX"
    export JELLYFISH2_0_LIBS=$PREFIX/lib/libjellyfish-2.0.dylib
else
    echo "Use *.so for Linux"
    export JELLYFISH2_0_LIBS=$PREFIX/lib/libjellyfish-2.0.so
fi

./configure --prefix=$PREFIX
make
make install
