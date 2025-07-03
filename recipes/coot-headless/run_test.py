import os

import coot_headless_api


os.chdir("data")
chapi = coot_headless_api.molecules_container_t(True)
imol = chapi.read_pdb("tutorial-modern.pdb")
imol_map = chapi.read_mtz("rnasa-1.8-all_refmac1.mtz", "FWT", "PHWT", "W", use_weight=False, is_a_difference_map=False)
chapi.auto_fit_rotamer(imol, "A", 44, "", "", imol_map)
chapi.set_imol_refinement_map(imol_map)
chapi.refine_residue_range(imol, chain_id="A", res_no_start=43, res_no_end=45, n_cycles=10)
chapi.write_coordinates(imol, "tutorial-modern-ref.pdb")
os.path.exists("tutorial-modern-ref.pdb")
