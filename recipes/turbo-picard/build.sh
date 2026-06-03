#!/usr/bin/env bash
set -euo pipefail

export OPENSSL_NO_VENDOR=1
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo fetch --locked

mkdir -p bioconda-patches
cp -R "${CARGO_HOME:-${HOME}/.cargo}"/registry/src/*/rust-htslib-1.0.0 \
  bioconda-patches/rust-htslib

python - <<'PY'
import pathlib

manifest = pathlib.Path("bioconda-patches/rust-htslib/Cargo.toml")
text = manifest.read_text()
old = (
    '[dependencies.hts-sys]\n'
    'version = "2.2.0"\n'
    'features = ["bindgen"]\n'
    'default-features = false'
)
new = (
    '[dependencies.hts-sys]\n'
    'version = "2.2.0"\n'
    'default-features = false'
)
if old not in text:
    raise SystemExit("rust-htslib hts-sys dependency block was not found")
manifest.write_text(text.replace(old, new))

workspace = pathlib.Path("Cargo.toml")
workspace.write_text(
    workspace.read_text()
    + '\n[patch.crates-io]\nrust-htslib = { path = "bioconda-patches/rust-htslib" }\n'
)
PY

cargo update -p rust-htslib --precise 1.0.0 --offline

cargo install \
  --locked \
  --no-track \
  --root "${PREFIX}" \
  --path crates/turbo-picard-cli \
  --bin turbo-picard
