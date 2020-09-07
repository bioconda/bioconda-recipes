#!/bin/bash

$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vvv .


# copy additional scripts
chmod +x tools/*.py
cp tools/*.py ${PREFIX}/bin


# copy download scripts
chmod +x data/*.py
cp data/setupGenomicData.py ${PREFIX}/bin
cp data/setupLogoData.py ${PREFIX}/bin


# create folder for database download
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db/


# copy config file where database is
cp ${RECIPE_DIR}/data.config ${target}/db/data.config
cp ${RECIPE_DIR}/data.config ${target}/db/data.config.user


# copy libraries, need to be in db folder
cp -r data/lib ${target}/db/
if [ `uname` == Darwin ]; then
    ln -s ${target}/db/lib/librgt_mac.so ${target}/db/lib/librgt.so
else
    ln -s ${target}/db/lib/librgt_linux.so ${target}/db/lib/librgt.so
fi


# copy script to download database
chmod +x ${RECIPE_DIR}/download-db.sh
cp ${RECIPE_DIR}/download-db.sh ${PREFIX}/bin


# set RGTDATA variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/rgt.sh
export RGTDATA=${target}/db/
export 	DOWNLOAD_URL=https://github.com/CostaLab/reg-gen/archive/${PKG_VERSION}.tar.gz
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/rgt.sh
unset RGTDATA
unset DOWNLOAD_URL
EOF
