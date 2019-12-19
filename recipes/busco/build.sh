#!/bin/bash

python setup.py install

mkdir -p $PREFIX/bin/
cp bin/busco $PREFIX/bin/busco #python script
cp scripts/generate_plot.py $PREFIX/bin/generate_plot.py
cp scripts/busco_configurator.py $PREFIX/bin/busco_configurator.py

SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $SHARE
cp config/config.ini.default $SHARE/config.ini.default
