#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod +x serotypefinder.py
cp serotypefinder.py ${PREFIX}/bin/serotypefinder

# copy script to download database
chmod +x ${RECIPE_DIR}/update-serotypefinder-db.sh
cp ${RECIPE_DIR}/update-serotypefinder-db.sh ${PREFIX}/bin/update-serotypefinder-db

# Grab latest database
# The SerotypeFinder database is not tagged and versioned, but it's also not updated
# very often (~7 commits in 5 years). ada62c62a7fa74032448bb2273d1f7045c59fdda is the
# latest commit as of 2022/05/16. A script is provided to allow users to update in the
# event an update is made.
mkdir database/
git clone https://bitbucket.org/genomicepidemiology/serotypefinder_db.git database/
cd database/
python3 INSTALL.py
git rev-parse HEAD > serotypefinder-db-commit.txt
cd ..

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
