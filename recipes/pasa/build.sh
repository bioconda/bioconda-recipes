#!/bin/sh

set -o errexit -o nounset

readonly PASAHOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

cd ${SRC_DIR}

# use the bioconda transdecoder instead of the bundled version
sed -i.bak 's#\$PLUGINS_DIR/transdecoder/##' Launch_PASA_pipeline.pl
sed -i.bak 's#"$transdecoder_dir/\(util\/\)*#"#' scripts/pasa_asmbls_to_training_set.dbi
# use bioconda cdbtools instead of the bundled version
sed -i.bak '/cdbtools/s/^/#/' Makefile
#fix compilers
sed -i.bak -e 's/\${CC}/${CXX}/g' Makefile

make

mkdir -p ${PASAHOME}
cp -Rp bin Launch_PASA_pipeline.pl misc_utilities pasa_conf PasaWeb PasaWeb.conf PerlLib PyLib run_PasaWeb.pl SAMPLE_HOOKS schema scripts ${PASAHOME}

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PASAHOME=${PASAHOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset PASAHOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
