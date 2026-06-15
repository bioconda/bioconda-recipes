#!/bin/bash

FDB_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p "${FDB_DIR}"
mkdir -p "${PREFIX}/bin"

cp -a . "${FDB_DIR}/"

chmod +x "${FDB_DIR}/famdb.py"

ln -sf "${FDB_DIR}/famdb.py" "${PREFIX}/bin/famdb.py"

for name in "${FDB_DIR}"/utils/*; do
    ln -sf "$name" "${PREFIX}/bin/$(basename "$name")"
done
