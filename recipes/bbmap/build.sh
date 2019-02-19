#!/bin/bash

set -x -e -o pipefail

BINARY_HOME=$PREFIX/bin
BBMAP_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $BBMAP_HOME

chmod a+x *.sh

cp -R * $BBMAP_HOME/

pushd $BBMAP_HOME/jni

export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

if test x"`uname`" = x"Linux"; then
    make -f makefile.linux
    ldd libbbtoolsjni.so
fi

if [ `uname` == Darwin ]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
    make -f makefile.osx
fi
rm -f *.o

popd

find *.sh -type f -exec ln -s $BBMAP_HOME/{} $BINARY_HOME/{} \;
