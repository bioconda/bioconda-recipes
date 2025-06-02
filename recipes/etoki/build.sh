#!/bin/bash

# Setup directories
SHARE_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION
mkdir -p $PREFIX/bin
mkdir -p $SHARE_DIR

# EToki expects a modules folder to be in same directory, let's use a symlink to SHARE_DIR
chmod 755 EToKi.py
cp EToKi.py $SHARE_DIR/EToKi.py
cp -r modules/ $SHARE_DIR
ln -s $SHARE_DIR/EToKi.py $PREFIX/bin/EToKi.py
