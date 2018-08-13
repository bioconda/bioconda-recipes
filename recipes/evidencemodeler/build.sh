#!/bin/sh

EVM_HOME=$PREFIX/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p $EVM_HOME

cp -R $SRC_DIR/simple_example $EVM_HOME/simple_example
cp -R $SRC_DIR/PerlLib $EVM_HOME/PerlLib
cp -R $SRC_DIR/EvmUtil $EVM_HOME/EvmUtils
cp $SRC_DIR/evidence_modeler.pl $EVM_HOME/evidence_modeler.pl

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVM_HOME=${EVM_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh