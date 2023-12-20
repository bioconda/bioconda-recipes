#!/usr/bin/env bash

set -x -e

mkdir -p "${PREFIX}/bin"

$CC $CFLAGS $LDFLAGS -o "${PREFIX}/bin/cluster_identifier" \
  "${SRC_DIR}/cluster_identifier/src/cluster_identifier.c" \
  -lz -lpthread -llzma -lbz2 -lcurl -lcrypto -lhts

cp -r "${SRC_DIR}/cluster_analysis/." "${PREFIX}/share/${PKG_NAME}"

cp "${RECIPE_DIR}/scramble.sh" "${PREFIX}/bin"
