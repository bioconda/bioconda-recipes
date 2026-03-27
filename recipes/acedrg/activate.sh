#!/bin/bash

export LIBMOL_ROOT="${CONDA_PREFIX}"
export CCP4="${CONDA_PREFIX}"
export CBIN="${CONDA_PREFIX}/bin"
export CLIBD_MON="${CONDA_PREFIX}/share/acedrg/tables/"

echo "LIBMOL_ROOT is set to ${LIBMOL_ROOT}"
echo "CCP4 is set to ${CCP4}"
echo "CBIN is set to ${CBIN}"
echo "CLIBD_MON is set to ${CLIBD_MON}"
