#!/bin/bash

# Add scripts
mkdir -p ${PREFIX}/bin
cp *.pl ${PREFIX}/bin
cp miniscripts/*.pl ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/*.pl

# copy script to download database
chmod 755 ${RECIPE_DIR}/download-vadr-models.sh ${RECIPE_DIR}/installed-vadr-models.sh ${RECIPE_DIR}/run-vadr-local-tests.sh
cp ${RECIPE_DIR}/download-vadr-models.sh ${RECIPE_DIR}/installed-vadr-models.sh ${RECIPE_DIR}/run-vadr-local-tests.sh ${PREFIX}/bin/

# Setup shared directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
VADR_DIR="${SHARE_DIR}/vadr"
VADRMODELDIR="${SHARE_DIR}/vadr-models"
mkdir -p ${VADR_DIR} ${VADRMODELDIR}
cp -r ./ ${VADR_DIR}/

# Install SARS-CoV-2 model (~15mb)
VADRMODELDIR="${VADRMODELDIR}" BIOCONDA_BUILD=1 bash -c '${PREFIX}/bin/download-vadr-models.sh sarscov2'

# Setup the VADR env variables
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
echo "export VADRVERSION=${PKG_VERSION}" > ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRINSTALLDIR=${PREFIX}" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRSCRIPTSDIR=${VADR_DIR}" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRMODELDIR=${VADRMODELDIR}" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRINFERNALDIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADREASELDIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRHMMERDIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRBIOEASELDIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRSEQUIPDIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRBLASTDIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export VADRFASTADIR=${PREFIX}/bin" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
echo "export PERL5LIB=${VADR_DIR}:${PERL5LIB}" >> ${PREFIX}/etc/conda/activate.d/vadr.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/vadr.sh

# Unset them
echo "unset VADRVERSION" > ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRINSTALLDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRSCRIPTSDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRMODELDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRINFERNALDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADREASELDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRHMMERDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRBIOEASELDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRSEQUIPDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRBLASTDIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset VADRFASTADIR" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
echo "unset PERL5LIB" >> ${PREFIX}/etc/conda/deactivate.d/vadr.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/vadr.sh

# Play nicely with Docker's --entrypoint
echo "#!/usr/bin/env bash" > ${PREFIX}/bin/vadr-run.sh
echo "for f in ${PREFIX}/etc/conda/activate.d/*; do source \${f}; done" >> ${PREFIX}/bin/vadr-run.sh
echo '"$@"' >> ${PREFIX}/bin/vadr-run.sh
chmod 755 ${PREFIX}/bin/vadr-run.sh
