#!/bin/bash
set -exo pipefail

export CCP4=$CONDA_PREFIX
export CBIN=$CONDA_PREFIX/bin
export CLIBD_MON=$CONDA_PREFIX/share/acedrg/tables/
export LIBMOL_ROOT=$CONDA_PREFIX

TMPDIR_TEST=$(mktemp -d)
cp ligand.smi "$TMPDIR_TEST/"
pushd "$TMPDIR_TEST"
acedrg -i ligand.smi -o AIN-acedrg
popd
