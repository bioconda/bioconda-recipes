#!/bin/bash

set -x -e -o pipefail

BINARY_HOME=$PREFIX/bin
BBMAP_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME
mkdir -p $BBMAP_HOME

chmod a+x *.sh

find . -type f -name *.o -exec rm -rf {} \;
cp -R * $BBMAP_HOME/

find *.sh -type f -exec ln -s $BBMAP_HOME/{} $BINARY_HOME/{} \;

python -c "import sys; print('Platform is %s' % sys.platform)"
