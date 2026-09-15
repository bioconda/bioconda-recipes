#!/bin/bash
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib/baysor"

# copy the entire bundled runtime
cp -r bin/baysor/* "${PREFIX}/lib/baysor/"

# make all files writable so conda-build can patch rpaths
chmod -R u+w "${PREFIX}/lib/baysor/"

# The depot path is baked into the sysimage by PackageCompiler and cannot
# be redirected via JULIA_DEPOT_PATH, so the directory must already exist
SCRATCH_DIR="${PREFIX}/lib/baysor/share/julia/scratchspaces/ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a/makie"
mkdir -p "${SCRATCH_DIR}"

# Add a placeholder file so the directory tree is actually included in the package.
# directory tree is actually included in the package.
touch "${SCRATCH_DIR}/.keep"

# fix permission so that the scratchspace can be used by any user of the package
chmod -R a+rwX "${PREFIX}/lib/baysor/share/julia/scratchspaces"

# wrapper script that sets the library path before running
cat > "${PREFIX}/bin/baysor" << 'WRAP'
#!/bin/bash
BAYSOR_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib/baysor" && pwd)"
exec env LD_LIBRARY_PATH="${BAYSOR_HOME}/lib:${LD_LIBRARY_PATH}" \
  "${BAYSOR_HOME}/bin/baysor" "$@"
WRAP
chmod +x "${PREFIX}/bin/baysor"
