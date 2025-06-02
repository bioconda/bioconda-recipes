#!/bin/bash

set -euxo pipefail

# Avoid libgit2 issues as much as humanly possible
export JULIA_PKG_USE_CLI_GIT=true

# Start a fake Julia depot
FAKEDEPOT="${PREFIX}/share/haplink/fake_depot"
export JULIA_DEPOT_PATH="${FAKEDEPOT}"

# Turn off automatic precompilation
export JULIA_PKG_PRECOMPILE_AUTO=0

# Copy the required files to a shared directory
HAPLINK_SRC_DIR=${PREFIX}/share/haplink/src
mkdir -p "${HAPLINK_SRC_DIR}"
cp -r {src,deps,example,Project.toml,Comonicon.toml} "${HAPLINK_SRC_DIR}"

# Work from the shared source directory
cd "${HAPLINK_SRC_DIR}" || exit 1

# Run the Comonicon install method
julia \
    --startup-file=no \
    --history-file=no \
    -e 'using Pkg; Pkg.develop(;path=pwd())'
julia \
    --startup-file=no \
    --history-file=no \
    "deps/build.jl"

# Create a permanent depot
HAPLINK_DEPOT="${PREFIX}/share/haplink/depot"
mkdir -p "${HAPLINK_DEPOT}"

# Copy the useful directories over to the permanent depot
for SUBDIR in "packages" "artifacts" "environments" "scratchspaces"; do
    mv "${FAKEDEPOT}/${SUBDIR}" "${HAPLINK_DEPOT}/${SUBDIR}"
done

# Copy the script to someplace more permanent
mkdir -p "${PREFIX}/bin"
mv "${JULIA_DEPOT_PATH}/bin/haplink" "${PREFIX}/bin"
sed -i -E 's%JULIA_PROJECT=.+%JULIA_PROJECT=\${CONDA_PREFIX}/share/haplink/depot/scratchspaces/8ca39d33-de0d-4205-9b21-13a80f2b7eed/env%' "${PREFIX}/bin/haplink"
sed -i -E 's%exec .+%exec ${CONDA_PREFIX}/bin/julia \\%' "${PREFIX}/bin/haplink"

# Destroy the fake depot
rm -rf "${FAKEDEPOT}"

# Add activation scripts
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
