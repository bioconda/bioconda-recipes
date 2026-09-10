#!/bin/bash
set -xeuo pipefail

# The GitHub archive has no .git, so pin the --version banner explicitly.
export BISMARK_SUITE_VERSION="${PKG_VERSION}"

# One `bismark` multicall binary. The rammap-inprocess + binseq-input features
# match the release build (both default-off); deps (incl. the rammap-core git dep)
# are fetched at build.
cargo build --release --locked \
    --manifest-path rust/Cargo.toml \
    -p bismark --bin bismark \
    --features bismark/rammap-inprocess,bismark/binseq-input

# conda's rust compiler sets CARGO_BUILD_TARGET, so the artifact is under
# target/<triple>/release; fall back to the plain (rustup) path.
BIN="rust/target/${CARGO_BUILD_TARGET:-}/release/bismark"
[ -f "$BIN" ] || BIN="rust/target/release/bismark"

install -d "${PREFIX}/bin"
install -m 0755 "$BIN" "${PREFIX}/bin/bismark"

# The 11 classic tool names are symlinks; the binary self-routes on argv[0].
cd "${PREFIX}/bin"
for b in deduplicate_bismark bismark_methylation_extractor bismark2bedGraph \
         coverage2cytosine bismark_genome_preparation bam2nuc NOMe_filtering \
         filter_non_conversion methylation_consistency bismark2report bismark2summary ; do
    ln -s bismark "$b"
done
