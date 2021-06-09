#!/bin/bash

# copy script
mkdir -p ${PREFIX}/bin/
cp *.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/*.py

# create directory for additional data
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}
cp -r rscripts ${target}
cp -r hmms ${target}

# set variables for data paths on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/fegenie.sh
export rscripts=${target}/rscripts/
export iron_hmms=${target}/hmms/iron/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/fegenie.sh
unset rscripts
unset iron_hmms
EOF
