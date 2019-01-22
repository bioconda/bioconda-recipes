#!/bin/bash

AMPTK_HOME=$PREFIX/opt/amptk-$PKG_VERSION

mkdir -p $AMPTK_HOME

cp -R $SRC_DIR/bin $AMPTK_HOME/bin
cp -R $SRC_DIR/util $AMPTK_HOME/util
cp -R $SRC_DIR/lib $AMPTK_HOME/lib
cp -R $SRC_DIR/DB $AMPTK_HOME/DB
ln -s $AMPTK_HOME/bin/amptk $PREFIX/bin/amptk
ln -s $AMPTK_HOME/util/bold2amptk.py $PREFIX/bin/bold2amptk.py
ln -s $AMPTK_HOME/util/bold2utax.py $PREFIX/bin/bold2utax.py
