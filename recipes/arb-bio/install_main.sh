#!/bin/bash

# Create [de]activate scripts
# (ARB components expect ARBHOME set to the installation directory)

mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >"${PREFIX}/etc/conda/activate.d/arbhome-activate.sh" <<EOF
export ARBHOME_BACKUP="\$ARBHOME"
export ARBHOME="\$CONDA_PREFIX/lib/arb"
EOF
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >"${PREFIX}/etc/conda/deactivate.d/arbhome-deactivate.sh" <<EOF
export ARBHOME="\$ARB_HOMEBACKUP"
EOF


cp -a install/* $PREFIX

(
    cd $PREFIX/bin
    for binary in ../lib/arb/bin/arb*; do
	ln -s "$binary"
    done
)
