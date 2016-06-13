#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
chmod a+x *novo*
cp isnovoindex novo2paf novoalign novoalignCS novoalignCSMPI novoalignMPI novobarcode novoindex novomethyl novope2bed.pl novorun.pl novosort novoutil $PREFIX/bin

SOURCE_FILE=$RECIPE_DIR/novoalign-license-register.sh
DEST_FILE=$PACKAGE_HOME/novoalign-license-register

cp "$SOURCE_FILE" "$DEST_FILE"

chmod +x $DEST_FILE
