#!/bin/bash
set -ex

# The cargo crate (package `te-core`; binaries dtr, te-discover, te-refine, te-seed) lives
# under core/. Use `cargo install` so binary placement does not depend on CARGO_TARGET_DIR
# (which the conda/bioconda build environment overrides) — building and reading from
# target/release/ directly is not reliable there.
cd core
export CARGO_NET_GIT_FETCH_WITH_CLI=true

cargo install --no-track --locked --root "$PREFIX" --path .

# dtr is the Step-4 entry point Pan_TE invokes; the others are its helpers.
for b in dtr te-discover te-refine te-seed; do
    test -x "$PREFIX/bin/$b" || { echo "te-looker: $b binary not produced" >&2; exit 1; }
done
