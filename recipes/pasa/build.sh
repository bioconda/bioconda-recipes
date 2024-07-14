#!/bin/bash

set -o errexit -o nounset

readonly PASAHOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

mkdir ${PREFIX}/bin
mkdir -p ${PASAHOME}

cd ${SRC_DIR}

# use the bioconda transdecoder instead of the bundled version
sed -i.bak 's#\$PLUGINS_DIR/transdecoder/##' Launch_PASA_pipeline.pl
sed -i.bak 's#"$transdecoder_dir/\(util\/\)*#"#' scripts/pasa_asmbls_to_training_set.dbi

# use bioconda cdbtools and slclust instead of the bundled version
sed -i.bak -e '/cdbtools/s/^/#/' -e '/slclust/s/^/#/' Makefile

make CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3" \
	INCLUDES="-I${PREFIX}/include" \
	LIBPATH="-L${PREFIX}/lib" -j4

cp -Rp bin Launch_PASA_pipeline.pl misc_utilities pasa_conf PasaWeb PasaWeb.conf PerlLib PyLib run_PasaWeb.pl SAMPLE_HOOKS schema scripts ${PASAHOME}
cp -Rp bin/* ${PREFIX}/bin/
cp -Rp PerlLib ${PREFIX}/bin/
ln -s -f ${PASAHOME}/Launch_PASA_pipeline.pl ${PREFIX}/bin/

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PASAHOME=${PASAHOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset PASAHOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh

make clean
