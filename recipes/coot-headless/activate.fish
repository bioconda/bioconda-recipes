set -x COOT_PREFIX $CONDA_PREFIX
echo "COOT_PREFIX set to $COOT_PREFIX"

set -x COOT_REFMAC_LIB_DIR $COOT_PREFIX/share/coot/lib
echo "COOT_REFMAC_LIB_DIR set to $COOT_REFMAC_LIB_DIR"

set -x CLIBD_MON $COOT_REFMAC_LIB_DIR/data/monomers
echo "CLIBD_MON set to $CLIBD_MON"

set -x COOT_STANDARD_RESIDUES $COOT_PREFIX/share/coot/standard-residues.pdb
echo "COOT_STANDARD_RESIDUES set to $COOT_STANDARD_RESIDUES"

set -x SYMINFO $COOT_PREFIX/share/coot/data/syminfo.lib
echo "SYMINFO set to $SYMINFO"
