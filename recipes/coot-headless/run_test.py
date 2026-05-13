import json
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
os.chdir("..")

# Additional ray-trace example using a separate PDB/MTZ input.
chapi = coot_headless_api.molecules_container_t(False)
imol = chapi.read_coordinates("3nir.pdb")
chapi.read_mtz("3nir_map.mtz", "FWT", "PHWT", "", use_weight=False, is_a_difference_map=False)

render_info = json.dumps({
    "molecules": {
        "0": {
            "colour_mode": "COLOUR-BY-CHAIN-AND-DICTIONARY",
            "bonds_width": 0.18,
            "atom_radius_to_bond_width_ratio": 1.2
        },
        "1": {
            "style": "lines",
            "map_radius": 12.0,
            "map_contour_level": 1.2,
            "map_line_width": 0.006,
            "map_colour": [0.5, 0.5, 0.9]
        }
    },
    "zoom": 4.5,
    "fovy": 1.0,
    "image_width": 1024,
    "image_height": 768,
    "output_file": "coot-ray-trace-3nir.png"
})

chapi.ray_trace_init()
chapi.ray_trace_image(render_info)
chapi.ray_trace_shutdown()
os.path.exists("coot-ray-trace-3nir.png")
