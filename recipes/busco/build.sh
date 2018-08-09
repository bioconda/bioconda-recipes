#!/bin/bash

mkdir -p $PREFIX/bin/
cp scripts/run_BUSCO.py $PREFIX/bin
cp scripts/generate_plot.py $PREFIX/bin

SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $SHARE
cp config/config.ini.default $SHARE/config.ini.default

ln -s $PREFIX/bin/run_BUSCO.py $PREFIX/bin/run_busco
ln -s $PREFIX/bin/generate_plot.py $PREFIX/bin/generate_plot

python setup.py install
