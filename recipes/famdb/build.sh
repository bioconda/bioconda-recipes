#!/bin/bash

FDB_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $FDB_DIR
mkdir -p "${PREFIX}/bin"
mv * ${FDB_DIR}

export LC_ALL="en_US.UTF-8"

# ----- add tools within the bin ------

# add famdb.py
ln -sf ${FDB_DIR}/famdb.py ${PREFIX}/bin/famdb.py

# add all utils
for name in ${FDB_DIR}/util/*; do
	ln -sf $name ${PREFIX}/bin/$(basename $name)
done
