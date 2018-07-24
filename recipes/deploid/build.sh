export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Moved from bootstrap
aclocal
autoconf
automake -a
./configure CPPFLAGS="$CPPFLAGS"--prefix=$PREFIX LDFLAGS="$LDFLAGS"
make
make install
