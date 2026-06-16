#!/usr/bin/env bash
set -euo pipefail

export OPENSSL_NO_VENDOR=1
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo fetch --locked

python - <<'PY'
import os
import pathlib
import shutil

cargo_home = pathlib.Path(os.environ.get("CARGO_HOME", pathlib.Path.home() / ".cargo"))
crate_dir = next(cargo_home.glob("registry/src/*/rust-htslib-1.0.0"))
patched_dir = pathlib.Path("target/bioconda-patches/rust-htslib-1.0.0").resolve()
if patched_dir.exists():
    shutil.rmtree(patched_dir)
shutil.copytree(crate_dir, patched_dir)
for name in ("Cargo.toml", "Cargo.toml.orig"):
    manifest = patched_dir / name
    text = manifest.read_text()
    updated = text.replace('features = ["bindgen"]\n', '').replace(', features = ["bindgen"]', '')
    if updated == text:
        raise SystemExit(f"rust-htslib hts-sys dependency block was not found in {name}")
    manifest.write_text(updated)

workspace_manifest = pathlib.Path("Cargo.toml")
workspace_manifest.write_text(
    workspace_manifest.read_text()
    + f'\n[patch.crates-io]\nrust-htslib = {{ path = "{patched_dir.as_posix()}" }}\n'
)
PY

cargo update --offline -p rust-htslib --precise 1.0.0

cargo install \
  --locked \
  --no-track \
  --root "${PREFIX}" \
  --path crates/turbo-picard-cli \
  --bin picard
