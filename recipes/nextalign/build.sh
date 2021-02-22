#!/usr/bin/env bash

chmod +x "${SRC_DIR}/nextalign-Linux-x86_64"
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}/nextalign-Linux-x86_64" "${PREFIX}/bin/nextalign"
