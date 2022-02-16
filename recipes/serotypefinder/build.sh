#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod +x serotypefinder.py
cp serotypefinder.py ${PREFIX}/bin/serotypefinder

# copy script to download database
chmod +x ${RECIPE_DIR}/update-serotypefinder-db.sh
cp ${RECIPE_DIR}/update-serotypefinder-db.sh ${PREFIX}/bin/update-serotypefinder-db

# Grab latest database
# The SerotypeFinder database is not tagged and versioned, but it's also not updated
# very often (~7 commits in 5 years). 25ddd141d245db6382ca5876f7c7ddd0288aeb30 is the
# latest commit as of 2021/07/22. A script is provided to allow users to update in the
# event an update is made.
curl https://bitbucket.org/genomicepidemiology/serotypefinder_db/get/25ddd141d245.zip > db.zip
unzip db.zip
rm db.zip
mv genomicepidemiology-serotypefinder_db-25ddd141d245 database
pushd database
python3 INSTALL.py
echo "25ddd141d245db6382ca5876f7c7ddd0288aeb30" > serotypefinder-db-commit.txt
popd

# Path for database
outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${outdir}/
mv ./database/ ${outdir}/

# set SEROTYPEFINDER_DB variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/serotypefinder.sh
export SEROTYPEFINDER_DB=${outdir}/database/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/serotypefinder.sh
unset SEROTYPEFINDER_DB
EOF
