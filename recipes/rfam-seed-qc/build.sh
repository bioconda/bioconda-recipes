#!/bin/bash
set -euo pipefail

# rfam-seed-qc is a set of scripts, not an installable Python package: copy them
# into share/ (validate_stockholm.py finds its scripts/ modules and VERSION file
# next to itself) and add wrapper commands to bin/.
share_dir="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${share_dir}/scripts" "${PREFIX}/bin"

install -m 0644 validate_stockholm.py VERSION LICENSE "${share_dir}/"
install -m 0644 scripts/*.py "${share_dir}/scripts/"

# Wrappers call this environment's own Python by full path, so they also work
# when the environment is not activated (pipelines, symlinks in ~/bin). conda
# rewrites ${PREFIX} in these files when the package is installed.
cat > "${PREFIX}/bin/rfam-seed-qc" <<EOF
#!/bin/bash
exec "${PREFIX}/bin/python" "${share_dir}/validate_stockholm.py" "\$@"
EOF

cat > "${PREFIX}/bin/rfam-seed-qc-build-live-cm" <<EOF
#!/bin/bash
exec "${PREFIX}/bin/python" "${share_dir}/scripts/build_live_cm.py" "\$@"
EOF

chmod 0755 "${PREFIX}/bin/rfam-seed-qc" "${PREFIX}/bin/rfam-seed-qc-build-live-cm"
