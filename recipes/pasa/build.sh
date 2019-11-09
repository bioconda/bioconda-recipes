#!/bin/sh

set -o errexit -o nounset

readonly PASAHOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

cd ${SRC_DIR}

make

mkdir -p ${PASAHOME}
cp -Rp bin Launch_PASA_pipeline.pl misc_utilities pasa_conf pasa-plugins PasaWeb PasaWeb.conf PerlLib PyLib run_PasaWeb.pl SAMPLE_HOOKS schema scripts ${PASAHOME}

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PASAHOME=${PASAHOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset PASAHOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
