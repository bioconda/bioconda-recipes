#!/usr/bin/env bash
set -euo pipefail

export OPENSSL_NO_VENDOR=1
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo fetch --locked

python - <<'PY'
import os
import pathlib

cargo_home = pathlib.Path(os.environ.get("CARGO_HOME", pathlib.Path.home() / ".cargo"))
manifest = next(cargo_home.glob("registry/src/*/rust-htslib-1.0.0/Cargo.toml"))
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
PY

cargo install \
  --locked \
  --no-track \
  --root "${PREFIX}" \
  --path crates/turbo-picard-cli \
  --bin picard
