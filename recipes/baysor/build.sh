#!/bin/bash

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib/baysor"

# copy the entire bundled runtime
cp -r bin/baysor/* "${PREFIX}/lib/baysor/"

# make all files writable so conda-build can patch rpaths
chmod -R u+w "${PREFIX}/lib/baysor/"

# create a wrapper script that sets library path before running
cat > "${PREFIX}/bin/baysor" << 'EOF'
#!/bin/bash
BAYSOR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib/baysor" && pwd)"
export LD_LIBRARY_PATH="${BAYSOR_HOME}/lib:${LD_LIBRARY_PATH}"

# Redirect all Julia/Makie writable paths away from the conda prefix
_TMPBASE="${TMPDIR:-/tmp}/baysor-$$"
mkdir -p "${_TMPBASE}"

export JULIA_DEPOT_PATH="${_TMPBASE}/julia-depot"
export JULIA_SCRATCH_PATH="${_TMPBASE}/julia-scratch"
export XDG_CACHE_HOME="${_TMPBASE}/xdg-cache"
export JULIA_PKG_PRECOMPILE_AUTO=0

mkdir -p "${JULIA_DEPOT_PATH}"
mkdir -p "${JULIA_SCRATCH_PATH}"
mkdir -p "${XDG_CACHE_HOME}"

exec "${BAYSOR_HOME}/bin/baysor" "$@"
EOF

chmod +x "${PREFIX}/bin/baysor"
