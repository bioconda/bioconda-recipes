
# that is necessary, otherwise the compilation will fail, because it is hardcoded to copy the docs/html
mkdir -p $SRC_DIR/docs/html

aclocal -I config  
autoconf
autoheader
automake -a

./configure --prefix=$PREFIX --exec-prefix=$PREFIX --bindir=$PREFIX/bin

make -j${CPU_COUNT}
make install
