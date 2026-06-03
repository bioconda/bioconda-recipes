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

replacements = {
    "src/bam/record.rs": [
        ("l: sam_copy.len(),", "l: sam_copy.len() as _,"),
        ("m: sam_copy.len(),", "m: sam_copy.len() as _,"),
        ("core.isize_", "core.isize"),
    ],
    "src/bam/mod.rs": [
        (
            "htslib::sam_hdr_parse(l_text + 1, text as *const c_char)",
            "htslib::sam_hdr_parse((l_text + 1) as _, text as *const c_char)",
        ),
        ("(*rec).l_text = l_text;", "(*rec).l_text = l_text as _;"),
    ],
    "src/bcf/record.rs": [
        ("htslib::kbs_init(remove.len())", "htslib::kbs_init(remove.len() as _)"),
    ],
    "src/bgzf/mod.rs": [
        (
            "htslib::bgzf_read(self.inner, buf.as_mut_ptr() as *mut libc::c_void, buf.len())",
            "htslib::bgzf_read(self.inner, buf.as_mut_ptr() as *mut libc::c_void, buf.len() as _)",
        ),
        (
            "htslib::bgzf_write(self.inner, buf.as_ptr() as *mut libc::c_void, buf.len())",
            "htslib::bgzf_write(self.inner, buf.as_ptr() as *mut libc::c_void, buf.len() as _)",
        ),
    ],
}
for relative, pairs in replacements.items():
    path = pathlib.Path("bioconda-patches/rust-htslib") / relative
    source = path.read_text()
    for old_text, new_text in pairs:
        if old_text not in source:
            raise SystemExit(f"{relative} did not contain expected text: {old_text}")
        source = source.replace(old_text, new_text)
    path.write_text(source)

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
  --bin picard
