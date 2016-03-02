#!/bin/bash

BINARY=Trinity
BINARY_HOME=$PREFIX/bin
TRINITY_HOME=$PREFIX/opt/trinity-$PKG_VERSION

cd $SRC_DIR

#make

# remove the sample data
rm -rf $SRC_DIR/sample_data

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $TRINITY_HOME
cp -R $SRC_DIR/* $TRINITY_HOME/
cd $TRINITY_HOME && chmod +x Trinity
cd $BINARY_HOME && ln -s $TRINITY_HOME/Trinity $BINARY
ln -s $TRINITY_HOME/util/* .
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/PtR
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/run_DE_analysis.pl
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'
