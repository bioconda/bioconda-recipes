#!/bin/bash

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PACKAGE_HOME
mkdir -p $PREFIX/bin

cp -r * $PACKAGE_HOME


WRAPPER=$PREFIX/bin/Jelly
echo "#!/bin/sh" > $WRAPPER
echo "$PACKAGE_HOME/bin/Jelly.py \$@" >> $WRAPPER
chmod +x $WRAPPER
