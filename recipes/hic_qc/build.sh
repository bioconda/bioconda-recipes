#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

export VERSION=1.2.913c977


cat <<EOF > pyproject.toml
[project]
name = "hic_qc"
description = "Quality assessment for Hi-C libraries"
version = "$VERSION"
EOF

${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

mkdir -p ${PREFIX}/bin
mv hic_qc.py ${PREFIX}/bin
chmod a+x ${PREFIX}/bin/hic_qc.py
ln -s ${PREFIX}/bin/hic_qc.py ${PREFIX}/bin/hic_qc

mkdir -p ${PREFIX}/bin/collateral
cp -r collateral/* ${PREFIX}/bin/collateral/
