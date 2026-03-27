#!/bin/bash
set -exo pipefail

export CCP4=$CONDA_PREFIX
export CBIN=$CONDA_PREFIX/bin
export CLIBD_MON=$CONDA_PREFIX/share/ccp4/lib/data/
export LIBMOL_ROOT=$CONDA_PREFIX

TMPDIR_TEST=$(mktemp -d)
cp ligand.smi "$TMPDIR_TEST/"
cd "$TMPDIR_TEST"
acedrg -i ligand.smi -o AIN-acedrg
