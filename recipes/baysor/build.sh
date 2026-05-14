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
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib/baysor/lib:${LD_LIBRARY_PATH}"
exec "${CONDA_PREFIX}/lib/baysor/bin/baysor" "$@"
EOF

chmod +x "${PREFIX}/bin/baysor"
