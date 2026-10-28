#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
install -m 0755 "${SRC_DIR}"/treeknit* "${PREFIX}/bin/treeknit"
