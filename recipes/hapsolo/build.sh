#!/bin/bash

mkdir -p ${PREFIX}/bin

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${outdir}

# Copy python scripts
cp *.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/hapsolo.py
chmod +x ${PREFIX}/bin/preprocessfasta.py

# Copy busco config 
cp -r busco3_config ${outdir}

# Copy example scripts
cp -r scripts ${outdir}

# create variable for example scripts
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/hapsolo.sh
export AUX_SCRIPTS=${outdir}/scripts/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/hapsolo.sh
unset AUX_SCRIPTS
EOF
