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
crate_dir = next(cargo_home.glob("registry/src/*/rust-htslib-1.0.0"))
replacements = {
    "Cargo.toml": (
        '[dependencies.hts-sys]\n'
        'version = "2.2.0"\n'
        'features = ["bindgen"]\n'
        'default-features = false',
        '[dependencies.hts-sys]\n'
        'version = "2.2.0"\n'
        'default-features = false',
    ),
    "Cargo.toml.orig": (
        'hts-sys = {version = "2.2.0", default-features = false, features = ["bindgen"]}',
        'hts-sys = {version = "2.2.0", default-features = false}',
    ),
}
for name, (old, new) in replacements.items():
    manifest = crate_dir / name
    text = manifest.read_text()
    if old not in text:
        raise SystemExit(f"rust-htslib hts-sys dependency block was not found in {name}")
    manifest.write_text(text.replace(old, new))
PY

cargo install \
  --locked \
  --no-track \
  --root "${PREFIX}" \
  --path crates/turbo-picard-cli \
  --bin turbo-picard
