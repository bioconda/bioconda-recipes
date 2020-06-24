#!/bin/bash


mkdir -p ${PREFIX}/bin
cp primer_core_tools.py ${PREFIX}/bin/rucs
cp install_db.sh ${PREFIX}/bin/install_db.sh
chmod +x ${PREFIX}/bin/rucs
chmod +x ${PREFIX}/bin/install_db.sh


# create folder for settings file
target=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${target}/db
touch ${target}/db/.empty

# copy settings file
cp settings.default.cjson ${target}/settings.default.cjson

# set variables on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/rucs.sh
export SETTINGS_FILE=${target}/settings.default.cjson
export BLASTDB=${target}/db/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/rucs.sh
unset SETTINGS_FILE
unset BLASTDB
EOF
