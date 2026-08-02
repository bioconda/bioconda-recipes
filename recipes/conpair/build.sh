#!/bin/bash
set -euo pipefail

# Conpair ships as a script tree (no setup.py); this script only places files. All source edits
# (py3 imports, portable shebang, self-contained CONPAIR_DIR/GATK_JAR defaults) are applied as
# patches, see meta.yaml.

# Move Python modules to site-packages to simulate a package install.
mkdir -p "${SP_DIR}"
cp modules/*.py "${SP_DIR}/"

# Move marker data to /share (scripts default CONPAIR_DIR here). The example/ pileups are
# test-only and intentionally not installed.
mkdir -p "${PREFIX}/share/conpair/data"
cp -r data/markers "${PREFIX}/share/conpair/data/"

# Move the primary and helper scripts to /bin.
mkdir -p "${PREFIX}/bin"
for src in scripts/*.py; do
    dst="${PREFIX}/bin/$(basename "${src}")"
    cp "${src}" "${dst}"
    chmod +x "${dst}"
done
