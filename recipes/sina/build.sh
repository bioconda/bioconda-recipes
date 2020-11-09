#!/bin/bash

export LDFLAGS="$LDFLAGS -Wl,-rpath -Wl,$PREFIX/lib"

./configure \
    --prefix=$PREFIX \
    --disable-docs \
    --with-arbhome=$PREFIX/lib/arb \
    --with-boost=$PREFIX \
    --with-boost-libdir=$PREFIX/lib \
    || (cat config.log; false)

make -j$CPU_COUNT
# Checks disabled because CircleCI macOS is <10.13 
# and lacks fmemopen (required only for tests)
# make check || (cat test-suite.log; false)

# Something is broken with libxkbcommon. make install will run
# ldconfig -n $PREFIX/lib, which creates symlinks for libraries,
# also making one that contains hex codes as file name that in 
# turn make conda build croak. This sidesteps the issue by
# removing the broken libraries.
rm -f $PREFIX/lib/libxkbcommon*

make install

# Many versions of `man` have a bug where it ignores files
# in `$PREFIX/share/man/` if `$PREFIX/man` is present. Since
# bzip2 installs it's files there, we need to as well.
mkdir -p $PREFIX/man/man1
mv $PREFIX/share/man/man1/sina.1 $PREFIX/man/man1
