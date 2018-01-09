#!/bin/sh

# install dependencies through pip
pip install -r requirements.txt

# remove unnecessary files from package before installing
rm ./.gitignore
rm -r ./images/

# install irida-sistr-results
mkdir $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp -r ./* $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/bin
ln -s $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/irida-sistr-results.py $PREFIX/bin/irida-sistr-results.py
