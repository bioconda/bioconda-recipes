#!/bin/bash

EVM_HOME=$PREFIX/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p $EVM_HOME

cp -R $SRC_DIR/EvmUtils $EVM_HOME/EvmUtils
cp -R $SRC_DIR/PerlLib $FEVM_HOME/PerlLib
ln -s $EVM_HOME/evidence_modeler.pl $PREFIX/bin/evidence_modeler.pl

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVM_HOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh