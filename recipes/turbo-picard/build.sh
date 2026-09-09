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

source_replacements = {
    "src/bam/record.rs": {
        "l: sam_copy.len(),": "l: sam_copy.len() as _,",
        "m: sam_copy.len(),": "m: sam_copy.len() as _,",
        "core.isize_": "core.isize",
    },
    "src/bam/mod.rs": {
        "htslib::sam_hdr_parse(l_text + 1, text as *const c_char)": (
            "htslib::sam_hdr_parse((l_text + 1) as _, text as *const c_char)"
        ),
        "(*rec).l_text = l_text;": "(*rec).l_text = l_text as _;",
    },
    "src/bcf/record.rs": {
        "htslib::kbs_init(remove.len())": "htslib::kbs_init(remove.len() as _)",
    },
    "src/bgzf/mod.rs": {
        "buf.len())": "buf.len() as _)",
    },
}
for relative_path, replacements in source_replacements.items():
    source = patched_dir / relative_path
    text = source.read_text()
    for old, new in replacements.items():
        if old not in text:
            raise SystemExit(f"rust-htslib source pattern was not found in {relative_path}: {old}")
        text = text.replace(old, new)
    source.write_text(text)

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
  --bin turbo-picard
