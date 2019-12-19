#!/bin/bash

python setup.py install

mkdir -p $PREFIX/bin/
cp scripts/run_BUSCO.py $PREFIX/bin/run_BUSCO.py
cp scripts/generate_plot.py $PREFIX/bin/generate_plot.py
cp scripts/busco_configurator.py $PREFIX/bin/busco_configurator.py

SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $SHARE
cp config/config.ini.default $SHARE/config.ini.default

# ln -s $PREFIX/bin/run_BUSCO.py $PREFIX/bin/run_busco
# ln -s $PREFIX/bin/run_BUSCO.py $PREFIX/bin/busco
# ln -s $PREFIX/bin/generate_plot.py $PREFIX/bin/generate_plot
