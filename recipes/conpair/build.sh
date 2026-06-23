#!/bin/bash
set -euo pipefail

# Conpair ships as a script tree (no setup.py); this script only places files. All source edits
# (py3 imports, portable shebang, self-contained CONPAIR_DIR/GATK_JAR defaults) are applied as
# patches, see meta.yaml.

# Move Python modules to site-packages to simulate a package install.
mkdir -p "${SP_DIR}"
cp modules/*.py "${SP_DIR}/"

# Move marker & genome data to /share.
mkdir -p "${PREFIX}/share/conpair"
cp -r data "${PREFIX}/share/conpair/"

# Move the primary and helper scripts to /bin.
mkdir -p "${PREFIX}/bin"
for src in scripts/*.py; do
    dst="${PREFIX}/bin/$(basename "${src}")"
    cp "${src}" "${dst}"
    chmod +x "${dst}"
done
