#!/bin/bash


mkdir -p $PREFIX/bin/
cp scripts/run_BUSCO.py $PREFIX/bin
cp scripts/generate_plot.py $PREFIX/bin

# To minimize $PREFIX/bin clutter, copy over the config.ini.default to the
# share directory, and put the config-generator script there as well. Then
# symlink only the script over to $PREFIX/bin. The script will resolve its own
# symlink to the share directory to find the config file, and replace paths in
# the config file with the (unresolved) symlink's directory, which is
# $PREFIX/bin.
SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $SHARE
cp config/config.ini.default $SHARE/config.ini.default
cp $RECIPE_DIR/generate-busco-config.py $SHARE/generate-busco-config.py
chmod +x $SHARE/generate-busco-config.py
ln -s $SHARE/generate-busco-config.py $PREFIX/bin/generate-busco-config.py

ln -s $PREFIX/bin/run_BUSCO.py $PREFIX/bin/run_busco
ln -s $PREFIX/bin/generate_plot.py $PREFIX/bin/generate_plot

python setup.py install
