import os

import coot_headless_api as chapi


os.chdir("data")
coot = chapi.molecules_container_t(True)
imol = coot.read_pdb("tutorial-modern.pdb")
imol_map = coot.read_mtz("rnasa-1.8-all_refmac1.mtz", "FWT", "PHWT", "W", use_weight=False, is_a_difference_map=False)
coot.auto_fit_rotamer(imol, "A", 44, "", "", imol_map)
coot.set_imol_refinement_map(imol_map)
coot.refine_residue_range(imol, chain_id="A", res_no_start=43, res_no_end=45, n_cycles=10)
coot.write_coordinates(imol, "tutorial-modern-ref.pdb")
os.path.exists("tutorial-modern-ref.pdb")
