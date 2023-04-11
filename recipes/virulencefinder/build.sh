#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod +x virulencefinder.py
cp virulencefinder.py ${PREFIX}/bin/virulencefinder.py

# copy script to download database
chmod +x ${RECIPE_DIR}/download-virulence-db.sh
cp ${RECIPE_DIR}/download-virulence-db.sh ${PREFIX}/bin/download-virulence-db.sh