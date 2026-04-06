#!/bin/bash
set -euxo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

# Generate third-party license file
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build the Rust binary from source, replacing the pre-built macOS binary
# shipped in annorefine.data/scripts/
maturin build --release --strip -v -j "${CPU_COUNT}"

# Find the binary (may be in target/<triple>/release/ or target/release/)
BINARY=$(find target -name annorefine -type f -executable -path "*/release/*" | head -1)
if [ -z "$BINARY" ]; then
    echo "ERROR: Could not find compiled annorefine binary"
    exit 1
fi
cp "$BINARY" annorefine.data/scripts/annorefine

# Build the Python extension (cdylib via maturin) and install
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
