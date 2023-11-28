#!/usr/bin/env bash

ls "${SRC_DIR}"
chmod +x "${SRC_DIR}"/nextclade*
mkdir -p "${PREFIX}/bin"
cp "${SRC_DIR}"/nextclade* "${PREFIX}"/bin/nextclade2
mv "${SRC_DIR}"/nextclade* "${PREFIX}"/bin/nextclade
