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
case `uname` in
  Darwin)
    # The build environment on CircleCI has a MacOS <10.13,
    # lacking `fmemopen`. This breaks one of the unit tests.
    # To work around that, running only the integration tests.
    make check-filtered P=^tests || (cat test-suite.log; false)
    ;;
  Linux)
    make check || (cat test-suite.log; false)
    ;;
esac
    
make install

# Many versions of `man` have a bug where it ignores files
# in `$PREFIX/share/man/` if `$PREFIX/man` is present. Since
# bzip2 installs it's files there, we need to as well.
mkdir -p $PREFIX/man/man1
mv $PREFIX/share/man/man1/sina.1 $PREFIX/man/man1
