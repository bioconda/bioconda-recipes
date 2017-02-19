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
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' run_MaxBin.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' _getabund.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' _getmarker.pl
# fix script's bin dir to follow symlinks
sed -i.bak 's|\$Bin|\$RealBin|' run_MaxBin.pl
chmod a+x *.pl

ln -s $MAXBIN_HOME/run_MaxBin.pl $PREFIX/bin/run_MaxBin.pl
