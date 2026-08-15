#!/usr/bin/env bash
set -euo pipefail

# Version information (if needed)
export VERSION=${PKG_VERSION}
export BUILD=${PKG_BUILDNUM}

make deploy
make philosopher

install -d "${PREFIX}/bin"
install philosopher "${PREFIX}/bin/philosopher"