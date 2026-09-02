#!/usr/bin/env bash
set -ex

export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS:-} -O3 -I${PREFIX}/include"
export CFLAGS="${CFLAGS:-} -O3 -I${PREFIX}/include"

# rust-htslib 0.49.0 + hts-sys 2.2.0 can generate opaque bindings
# in this build environment; force the last known compatible pair.
sed -i 's/^rust-htslib = .*/rust-htslib = "=0.48.0"/' Cargo.toml
cargo update -p rust-htslib --precise 0.48.0
cargo update -p hts-sys --precise 2.1.4

# Force a local rust-htslib patch to disable hts-sys bindgen reliably.
cargo fetch --locked
python - <<'PY'
from pathlib import Path
import os
import shutil

cargo_home = Path(os.environ["CARGO_HOME"])
matches = list(cargo_home.glob("registry/src/*/rust-htslib-0.48.0"))
if not matches:
    raise SystemExit("Could not locate rust-htslib-0.48.0 in cargo registry")

src = matches[0]
vendor = Path("vendor/rust-htslib-0.48.0")
if vendor.exists():
    shutil.rmtree(vendor)
shutil.copytree(src, vendor)

cargo_toml = vendor / "Cargo.toml"
text = cargo_toml.read_text()
text = text.replace('features = ["bindgen"]', '')
text = text.replace(', ,', ',')
cargo_toml.write_text(text)

# Compatibility patch for newer prebuilt hts-sys bindings (size_t/u64 and isize field name).
def patch_file(path, old, new):
    p = vendor / path
    t = p.read_text()
    if old in t:
        p.write_text(t.replace(old, new))

patch_file("src/bam/record.rs", "l: sam_copy.len(),", "l: sam_copy.len() as _,")
patch_file("src/bam/record.rs", "m: sam_copy.len(),", "m: sam_copy.len() as _,")
patch_file("src/bam/record.rs", "core.isize_", "core.isize")
patch_file("src/bam/mod.rs", "(*rec).l_text = l_text;", "(*rec).l_text = l_text as _;")
patch_file("src/bam/mod.rs", "sam_hdr_parse((l_text + 1), text as *const c_char);", "sam_hdr_parse((l_text + 1) as _, text as *const c_char);")
patch_file("src/bcf/record.rs", "htslib::kbs_init(remove.len())", "htslib::kbs_init(remove.len() as _)")
patch_file("src/bgzf/mod.rs", "buf.len())", "buf.len() as _)")

root = Path("Cargo.toml")
root_text = root.read_text()
if "[patch.crates-io]" not in root_text:
    root_text += '\n[patch.crates-io]\n'
if 'rust-htslib = { path = "vendor/rust-htslib-0.48.0" }' not in root_text:
    root_text += 'rust-htslib = { path = "vendor/rust-htslib-0.48.0" }\n'
root.write_text(root_text)
print("Patched local vendor/rust-htslib-0.48.0 and root Cargo.toml")
PY

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install -v --locked --no-track --root "${PREFIX}" --path .
