#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

# There is some issue here building with Python 3.8 on macOS >= 11
# See https://github.com/pypa/cibuildwheel/issues/1410
export MACOSX_DEPLOYMENT_TARGET=12.7
export MACOS_DEPLOYMENT_TARGET=12.7
export SYSTEM_VERSION_COMPAT=0

# See https://github.com/conda/conda-build/issues/4392#issuecomment-1370281802
if [[ $target_platform == osx-* ]]; then
    for toolname in "otool" "install_name_tool"; do
        tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname")
        mv "${tool}" "${tool}.bak"
        ln -s "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
    done
fi

# Build statically linked binary with Rust
# Note: This sdist is a bit wonky because it was generated from a monorepo by running maturin sdist
RUST_BACKTRACE=1 

# Creating the sdist from the monorepo placed pyproject.toml one level above Cargo.toml.
# The wheels don't seem to install as expected unless pyproject.toml is moved back into the source dir.
mv pyproject.toml pybigtools/

# Run maturin build to produce *.whl files.
maturin build -m pybigtools/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install *.whl files using pip
${PYTHON} -m pip install pybigtools/target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

# Move the LICENSE file to the root dir
mv pybigtools/LICENSE .
