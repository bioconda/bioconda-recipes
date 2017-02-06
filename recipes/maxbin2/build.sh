#!/bin/bash

MAXBIN_HOME=$PREFIX/opt/MaxBin-$PKG_VERSION

# make
cp makefile.new $SRC_DIR/src
cd $SRC_DIR/src
make -f makefile.new

mkdir -p $PREFIX/bin
mkdir -p $MAXBIN_HOME
cp -R $SRC_DIR/* $MAXBIN_HOME/

cd $MAXBIN_HOME
# fix perl path
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' run_MaxBin.pl
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' _getabund.pl
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' _getmarker.pl
# fix script's bin dir to follow symlinks
sed -i.bak 's|\$Bin|\$RealBin|' run_MaxBin.pl
chmod a+x *.pl

ln -s $MAXBIN_HOME/run_MaxBin.pl $PREFIX/bin/run_MaxBin.pl
