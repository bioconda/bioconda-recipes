#!/bin/bash

EVM_HOME=$PREFIX/opt/evidencemodeler-$PKG_VERSION

mkdir -p $EVM_HOME

cp -R $SRC_DIR/EvmUtils $EVM_HOME/EvmUtils
cp -R $SRC_DIR/PerlLib $FEVM_HOME/PerlLib
ln -s $EVM_HOME/evidence_modeler.pl $PREFIX/bin/evidence_modeler.pl