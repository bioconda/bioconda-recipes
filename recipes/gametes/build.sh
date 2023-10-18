#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp $RECIPE_DIR/gametes.py $PACKAGE_HOME/gametes.py


JAR=./GAMETES_2.1.jar

mv $JAR $PACKAGE_HOME/

chmod +x $PACKAGE_HOME/*.{py,jar}

ln -s $PACKAGE_HOME/gametes.py $PREFIX/bin/GAMETES_2.1

