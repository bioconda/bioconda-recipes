#!/bin/bash

set -euxo pipefail

# Avoid libgit2 issues when Pkg fetches the registry and packages
export JULIA_PKG_USE_CLI_GIT=true
# Precompile explicitly below instead of on every Pkg operation
export JULIA_PKG_PRECOMPILE_AUTO=0

# FADU is a Julia package; install it (with test/data, which the precompile
# workload and the recipe test both use) into a shared directory
FADU_HOME="${PREFIX}/share/fadu"
mkdir -p "${FADU_HOME}" "${PREFIX}/bin"
cp -r Project.toml Manifest.toml fadu.jl src test "${FADU_HOME}/"

# Install the pinned dependencies from Manifest.toml into a private depot and precompile
export JULIA_DEPOT_PATH="${FADU_HOME}/depot"
export JULIA_PROJECT="${FADU_HOME}"
julia --startup-file=no --history-file=no \
    -e 'using Pkg; Pkg.instantiate(); Pkg.precompile(); using FADU'

# Not needed at runtime (wrapper runs Pkg offline)
rm -rf "${JULIA_DEPOT_PATH}/registries" "${JULIA_DEPOT_PATH}/logs" "${JULIA_DEPOT_PATH}/clones"

# Wrapper so `fadu` works without activating the environment
cat > "${PREFIX}/bin/fadu" <<'EOF'
#!/usr/bin/env bash
FADU_HOME="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../share/fadu" && pwd)"
# Leading ":" puts the user's default depot first (writable, for any recompiles),
# followed by the depot bundled with FADU
export JULIA_DEPOT_PATH=":${FADU_HOME}/depot"
export JULIA_PKG_OFFLINE=true
exec julia --startup-file=no --history-file=no --project="${FADU_HOME}" "${FADU_HOME}/fadu.jl" "$@"
EOF
chmod +x "${PREFIX}/bin/fadu"
