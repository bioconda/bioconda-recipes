#!/bin/sh

set -o errexit -o nounset

readonly PASAHOME=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

cd ${SRC_DIR}

# use the bioconda transdecoder instead of the bundled version
sed -i.bak 's#\$PLUGINS_DIR/transdecoder/##' Launch_PASA_pipeline.pl
sed -i.bak 's#"$transdecoder_dir/\(util\/\)*#"#' scripts/pasa_asmbls_to_training_set.dbi
# use bioconda cdbtools instead of the bundled version
sed -i.bak '/cdbtools/s/^/#/' Makefile
# fix compilers; $CC and $CXX used incorrectly...
sed -i.bak -e 's/CPPC = \${CC}/CPPC = ${CXX}/' -e 's/CC = g++/#CC = /' pasa_cpp/Makefile
sed -i.bak -e 's/^CC/#CC/' -e 's/\${CC}/${CXX} ${CFLAGS}/g' pasa-plugins/slclust/src/Makefile
sed -i.bak -e 's/gcc/${CC}/g' pasa-plugins/seqclean/mdust/Makefile
sed -i.bak -e 's/^CC/#CC/' pasa-plugins/seqclean/psx/Makefile
sed -i.bak -e 's/gcc/${CC}/g' pasa-plugins/seqclean/trimpoly/Makefile

if [ `uname` == Darwin ]; then
	CXXFLAGS="${CXXFLAGS} -g -O3 -I${PREFIX}/include"
else
	CXXFLAGS="${CXXFLAGS} -g -O3"
fi

make

mkdir -p ${PASAHOME}
cp -Rp bin Launch_PASA_pipeline.pl misc_utilities pasa_conf PasaWeb PasaWeb.conf PerlLib PyLib run_PasaWeb.pl SAMPLE_HOOKS schema scripts ${PASAHOME}

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PASAHOME=${PASAHOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset PASAHOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
