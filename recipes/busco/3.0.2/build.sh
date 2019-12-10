#!/bin/bash
python setup.py install

mkdir -p $PREFIX/bin/
cp scripts/run_BUSCO.py $PREFIX/bin
cp scripts/generate_plot.py $PREFIX/bin

SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $SHARE
cp config/config.ini.default $SHARE/config.ini.default



cd $PREFIX/bin/
cp run_BUSCO.py run_busco
cp generate_plot.py generate_plot
# I'don't know why ymlink doesn't work
