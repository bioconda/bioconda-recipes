# Coot environment variables
export COOT_PREFIX="${CONDA_PREFIX}"
echo "COOT_PREFIX set to ${COOT_PREFIX}"

export COOT_REFMAC_LIB_DIR="${COOT_PREFIX}/share/coot/lib"
echo "COOT_REFMAC_LIB_DIR set to ${COOT_REFMAC_LIB_DIR}"

export CLIBD_MON="${COOT_REFMAC_LIB_DIR}/data/monomers"
echo "CLIBD_MON set to ${CLIBD_MON}"

export COOT_STANDARD_RESIDUES="${COOT_PREFIX}/share/coot/standard-residues.pdb"
echo "COOT_STANDARD_RESIDUES set to ${COOT_STANDARD_RESIDUES}"

export SYMINFO="${COOT_PREFIX}/share/coot/data/syminfo.lib"
echo "SYMINFO set to ${SYMINFO}"

