#!/bin/bash
# Install SpecImmune under $PREFIX/share/specimmune and add bin wrappers.
# Expects conda-build env: SRC_DIR = extracted tarball root, PREFIX = install prefix.

set -e

INSTALL_DIR="${PREFIX}/share/specimmune"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${PREFIX}/bin"

# Copy required dirs (relative to repo root from tarball)
for d in scripts bin gene_dist packages drug_db; do
  if [[ -d "${SRC_DIR}/${d}" ]]; then
    cp -R "${SRC_DIR}/${d}" "${INSTALL_DIR}/"
  fi
done

# Empty db dir so default --db points to a valid path; user runs specimmune-make-db to populate
mkdir -p "${INSTALL_DIR}/db"

# Main typing pipeline
cat << EOF > "${PREFIX}/bin/specimmune"
#!/bin/bash
exec "${PYTHON}" "${INSTALL_DIR}/scripts/main.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/specimmune"

# Database construction
cat << EOF > "${PREFIX}/bin/specimmune-make-db"
#!/bin/bash
exec "${PYTHON}" "${INSTALL_DIR}/scripts/make_db.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/specimmune-make-db"

# ExtractReads.sh (optional helper)
if [[ -f "${INSTALL_DIR}/scripts/ExtractReads.sh" ]]; then
  cat << EOF > "${PREFIX}/bin/specimmune-extract-reads"
#!/bin/bash
exec bash "${INSTALL_DIR}/scripts/ExtractReads.sh" "\$@"
EOF
  chmod +x "${PREFIX}/bin/specimmune-extract-reads"
fi
