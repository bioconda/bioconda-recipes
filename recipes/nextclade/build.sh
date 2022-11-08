#!/usr/bin/env bash

ls "${SRC_DIR}"
chmod +x "${SRC_DIR}"/nextclade*
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}"/nextclade* "${PREFIX}"/bin/nextclade
