#!/bin/bash
set -xeuo pipefail

# conda_build hoists the single top-level directory out of our tarball,
# so trim_galore + LICENSE land directly in $SRC_DIR.
mkdir -p "${PREFIX}/bin"
install -m 0755 trim_galore "${PREFIX}/bin/trim_galore"
