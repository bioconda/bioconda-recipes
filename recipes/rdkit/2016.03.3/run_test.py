# plot a simple molecule; requires pillow
from rdkit import Chem
from rdkit.Chem import AllChem
from rdkit.Chem import Draw
comp = Chem.MolFromSmiles('CN1C=NC2=C1C(=O)N(C)C(=O)N2C')
comp.UpdatePropertyCache(strict=False)
AllChem.Compute2DCoords(comp)
Draw.MolToFile(comp, 'test_pillow_caffeine.png')
