#!/bin/sh

EVM_HOME=$PREFIX/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p $EVM_HOME

cp -R $SRC_DIR/ $EVM_HOME/

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVM_HOME=${EVM_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh