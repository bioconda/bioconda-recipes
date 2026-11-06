set -gx COOT_PREFIX $CONDA_PREFIX
set -gx COOT_REFMAC_LIB_DIR $COOT_PREFIX/share/coot/lib
set -gx CLIBD_MON $COOT_REFMAC_LIB_DIR/data/monomers/
set -gx COOT_STANDARD_RESIDUES $COOT_PREFIX/share/coot/standard-residues.pdb
set -gx SYMINFO $COOT_PREFIX/share/coot/data/syminfo.lib
