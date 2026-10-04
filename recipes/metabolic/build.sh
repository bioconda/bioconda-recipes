#!/bin/sh
set -e

mkdir -p "${PREFIX}/bin"

cp METABOLIC-C.pl METABOLIC-G.pl METABOLIC-C.2nd_run.pl "${PREFIX}/bin/"
chmod +x "${PREFIX}"/bin/METABOLIC-*.pl

cp create_excel_spreadsheet.R draw_biogeochemical_cycles.R \
   draw_functional_network_diagram.R draw_metabolic_Sankey_diagram.R \
   draw_sequential_reaction_diagram.R "${PREFIX}/bin/"

cp All_Module_KO_ids.txt "${PREFIX}/bin/"

tar -xzf Accessory_scripts.tgz -C "${PREFIX}/bin/"

cp METABOLIC_hmm_db.tgz METABOLIC_template_and_database.tgz "${PREFIX}/bin/"
