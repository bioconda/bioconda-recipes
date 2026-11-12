#!/usr/bin/env bash
# .cargo/config.toml sets target-cpu to x86-64-v3 and neoverse-v1. RUSTFLAGS
# replaces those rustflags, so this package uses the generic CPU floors.
set -euo pipefail

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64|Darwin-x86_64) cpu=x86-64-v2 ;;
  Linux-aarch64) cpu=generic ;;
  Darwin-arm64) cpu=apple-m1 ;;
  *)
    echo "ERROR: [bioconda] no CPU floor for $(uname -s)-$(uname -m)" >&2
    exit 1
    ;;
esac
export RUSTFLAGS="-C target-cpu=${cpu}"

# vep-cache-builder links OpenSSL through reqwest on Linux. conda-forge's
# OpenSSL is built for glibc 2.17, which is the release binaries' floor.
if [ "$(uname -s)" = "Linux" ]; then
  export OPENSSL_DIR="${PREFIX}"
  export OPENSSL_NO_VENDOR=1
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo build --release --locked \
  --bin vep \
  --bin vep-cache-builder \
  --bin vep-cache-converter

install -d "${PREFIX}/bin"
install -m 0755 \
  target/release/vep \
  target/release/vep-cache-builder \
  target/release/vep-cache-converter \
  "${PREFIX}/bin/"
