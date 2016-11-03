# tests for openbabel in python

# A test of some smiple SMILES manipulation
# by Richard West <r.west@neu.edu>
# Three SMILES, first two obviously the same, third one a resonance isomer.
smis=['[CH2]C=CCO', 'C([CH2])=CCO','C=C[CH]CO']

import pybel
canonicals = [pybel.readstring("smi", smile).write("can").strip() for smile in smis]
assert len(canonicals) == 3
assert len(set(canonicals)) == 2
# go via InChI to recognize resonance isomer
inchis = [pybel.readstring("smi", smile).write("inchi").strip() for smile in smis]
canonicals = [pybel.readstring("inchi", inchi).write("can").strip() for inchi in inchis]
assert len(set(canonicals)) == 1
