#!/bin/sh

set -o errexit -o nounset

readonly EVM_HOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

mkdir -p ${EVM_HOME}

cp -Rp simple_example PerlLib EvmUtils evidence_modeler.pl ${EVM_HOME}
ln -s ${EVM_HOME}/evidence_modeler.pl ${PREFIX}/bin/evidence_modeler.pl

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export EVM_HOME=${EVM_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset EVM_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh