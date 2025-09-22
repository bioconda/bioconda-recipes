#!/usr/bin/env bash
set -euxo pipefail

# Standard flags
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

# Keep cargo cache local to the build dir (avoid writing to $HOME)
export CARGO_HOME="$(pwd)/.cargo-cache"

# Bundle third-party licenses for Rust deps
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build and install Rust binaries into $PREFIX/bin reproducibly
cargo install --locked --no-track --root "${PREFIX}" --path .

# Remove cargo metadata files that shouldn't ship in the prefix
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json" || true

# Install R scripts (they already have a proper Rscript shebang)
install -d "${PREFIX}/bin"
shopt -s nullglob
for src in scripts/*; do
  [[ -f "${src}" ]] || continue
  install -m 0755 "${src}" "${PREFIX}/bin/"
done
