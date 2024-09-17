#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -R ${SRC_DIR}/bin/* ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/tiberius.py  # Rendre le fichier exécutable
ln -s ${PREFIX}/bin/tiberius.py ${PREFIX}/bin/tiberius 