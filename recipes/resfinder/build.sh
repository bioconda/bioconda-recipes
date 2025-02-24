#!/bin/bash -ex

mkdir -p ${PREFIX}/bin

${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir

# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/
touch ${target}/db/.empty

# copy script to download database
cp -rf ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin
chmod 0755 ${PREFIX}/bin/download-db.sh

# set RESFINDER_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/resfinder.sh
export RESFINDER_DB=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/resfinder.sh
unset RESFINDER_DB
EOF

chmod 0755 ${SP_DIR}/resfinder/run_resfinder.py
cp -rf ${SP_DIR}/resfinder/run_resfinder.py ${PREFIX}/bin/
