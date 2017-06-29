#!/bin/bash
set -eu

PACKAGE_HOME=$PREFIX/bin

mkdir -p $PACKAGE_HOME
chmod a+x *novo*
cp isnovoindex novo2paf novoalign novoalignCS novoalignCSMPI novoalignMPI novobarcode novoindex novomethyl novope2bed.pl novorun.pl novosort novoutil $PACKAGE_HOME

SOURCE_FILE=$RECIPE_DIR/novoalign-license-register.sh
DEST_FILE=$PACKAGE_HOME/novoalign-license-register

cp "$SOURCE_FILE" "$DEST_FILE"

chmod +x $DEST_FILE
