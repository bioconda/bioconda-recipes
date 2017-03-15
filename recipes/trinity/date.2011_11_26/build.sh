#!/bin/bash

# Mach-O format for custom stack size changed in Mountain Lion (10.8)
MACOSX_DEPLOYMENT_TARGET=10.9
BINARY=Trinity
BINARY_HOME=$PREFIX/bin
TRINITY_HOME=$PREFIX/opt/trinity-$PKG_VERSION

cd $SRC_DIR

export CPATH=${PREFIX}/include

make

# remove the sample data
rm -rf $SRC_DIR/sample_data

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $TRINITY_HOME
cp -R $SRC_DIR/* $TRINITY_HOME/
cd $TRINITY_HOME && chmod +x Trinity.pl

echo $'#!/bin/sh' > $TRINITY_HOME/Trinity-runner.sh
echo $'cd $(dirname $0)/$(dirname $(readlink $0) )' >> $TRINITY_HOME/Trinity-runner.sh
echo $'./Trinity.pl $@' >> $TRINITY_HOME/Trinity-runner.sh

echo $'#!/bin/sh' > $TRINITY_HOME/Trinity-test.sh
echo $'cd $(dirname $0)/$(dirname $(readlink $0) )' >> $TRINITY_HOME/Trinity-test.sh
echo $'perl -c ./Trinity.pl &> /dev/null' >> $TRINITY_HOME/Trinity-test.sh

chmod +x $TRINITY_HOME/Trinity-*.sh

cd $BINARY_HOME
ln -s $TRINITY_HOME/Trinity-runner.sh $BINARY
ln -s $TRINITY_HOME/Trinity-test.sh "$BINARY-test"
