#!/bin/bash
set -euo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export HDF5_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# hdf5-sys 0.8.1 has a copy-paste bug at src/h5p.rs:538 — H5Pget_fapl_direct
# is gated on feature="have-parallel" instead of "have-direct". When HDF5
# is built with direct VFD but without MPI (the conda-forge default), the
# hdf5 wrapper crate's `have-direct` cfg becomes TRUE and tries to import
# H5Pget_fapl_direct, but hdf5-sys's `have-parallel` cfg is FALSE so the
# symbol isn't declared. Patching H5pubconf.h in the (ephemeral) host env
# to suppress H5_HAVE_DIRECT keeps the wrapper crate's import path dead
# code, which is fine because rastqc's nanopore features don't use the
# direct VFD. Remove this workaround once upstream migrates off hdf5 0.8.
if [ -f "${PREFIX}/include/H5pubconf.h" ]; then
    chmod u+w "${PREFIX}/include/H5pubconf.h"
    sed -i '/^#define H5_HAVE_DIRECT[[:space:]]/d' "${PREFIX}/include/H5pubconf.h"
fi

cargo install --no-track --locked --root "${PREFIX}" --path . --bin rastqc \
  --features nanopore

# Rename so this variant can coexist with the core `rastqc` package in the same env.
mv "${PREFIX}/bin/rastqc" "${PREFIX}/bin/rastqc-nanopore"
