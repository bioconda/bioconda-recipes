#!/bin/bash
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib/baysor"

# copy the entire bundled runtime
cp -r bin/baysor/* "${PREFIX}/lib/baysor/"

# make all files writable so conda-build can patch rpaths
chmod -R u+w "${PREFIX}/lib/baysor/"

# Pre-create the FULL scratchspace path that Makie's __init__ tries to
# mkdir during sysimage init (before any env override can take effect).
# The depot path is baked into the sysimage by PackageCompiler and cannot
# be redirected via JULIA_DEPOT_PATH, so the directory must already exist
# AT RUNTIME.
SCRATCH_DIR="${PREFIX}/lib/baysor/share/julia/scratchspaces/ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a/makie"
mkdir -p "${SCRATCH_DIR}"

# conda packaging is file-driven: an EMPTY directory has no manifest entry
# and will NOT be recreated on install. Add a placeholder file so the
# directory tree is actually included in the package.
touch "${SCRATCH_DIR}/.keep"

# The runtime user (e.g. inside a mulled-test container) is not the build
# user, so the directory must be writable/traversable by ANY uid, not just
# the owner. a+rwX = rw for all, execute only on directories.
chmod -R a+rwX "${PREFIX}/lib/baysor/share/julia/scratchspaces"

# create a wrapper script that sets the library path before running
cat > "${PREFIX}/bin/baysor" << 'WRAP'
#!/bin/bash
BAYSOR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib/baysor" && pwd)"
exec env LD_LIBRARY_PATH="${BAYSOR_HOME}/lib:${LD_LIBRARY_PATH}" \
  "${BAYSOR_HOME}/bin/baysor" "$@"
WRAP
chmod +x "${PREFIX}/bin/baysor"
