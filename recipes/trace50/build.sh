#!/bin/bash
set -ex

# The Python package lives in the trace50/ subdirectory of the HyphAeon
# monorepo; its maturin manifest-path resolves workspace members via the
# repo-root rust/Cargo.toml, which the tarball provides.
cd trace50
${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

# mulled-build does not stage test.files inside the biocontainer, so the
# smoke-test alignment ships inside the package itself.
mkdir -p "${PREFIX}/share/trace50"
cp "${RECIPE_DIR}/demo_outbreak.fasta" "${PREFIX}/share/trace50/"
