#!/usr/bin/env bash

ls "${SRC_DIR}"
chmod +x "${SRC_DIR}"/rebar*
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}"/rebar* "${PREFIX}"/bin/rebar
