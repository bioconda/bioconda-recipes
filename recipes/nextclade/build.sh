#!/usr/bin/env bash

chmod +x "${SRC_DIR}"/nextclade*
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}"/nextclade* "${PREFIX}"/bin/nextclade
