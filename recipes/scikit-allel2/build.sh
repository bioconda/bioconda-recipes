#!/bin/bash
set -euxo pipefail

# licenses of the Rust crates compiled into the extension
(cd rust/io_vcf_read && cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml")

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vv
