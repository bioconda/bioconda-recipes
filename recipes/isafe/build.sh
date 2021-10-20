#!/bin/sh

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME $PACKAGE_HOME

rm -rf example

2to3 -w -n --nofix=import .

mv src/isafe.py src/isafe.py.tmp
echo '#!/usr/bin/env python3' > src/isafe.py
cat src/isafe.py.tmp >> src/isafe.py
rm src/isafe.py.tmp

cp -r * $PACKAGE_HOME

chmod u+x ${PACKAGE_HOME}/src/isafe.py
ln -s ${PACKAGE_HOME}/src/isafe.py ${BINARY_HOME}/isafe.py
