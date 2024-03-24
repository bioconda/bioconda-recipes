#!/usr/bin/env bash
ls "${SRC_DIR}"
chmod +x "${SRC_DIR}/tw"
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}"/tw ${PREFIX}/bin/tw
