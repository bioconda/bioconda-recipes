#!/bin/bash

DATA_DIR="$PREFIX/share/hymet/data"

cat > "$PREFIX/.messages.txt" << EOF

Thank you for installing HYMET (Hybrid Metagenomic Tool)!

The full repository (Python CLI + legacy Perl pipeline) now lives under:
  $PREFIX/share/hymet

Before running \`hymet run\`, download the public Mash sketches:

1. Fetch these files from https://drive.google.com/drive/folders/1YC0N77UUGinFHNbLpbsucu1iXoLAM6lm
     - sketch1.msh.gz
     - sketch2.msh.gz
     - sketch3.msh.gz
2. Place them inside:
     $DATA_DIR
3. Decompress each archive:
     gunzip $DATA_DIR/sketch*.msh.gz
4. Prime the taxonomy cache (downloads NCBI dumps as needed):
     hymet-config

Use \`hymet run --help\` for the Python CLI, or \`hymet-legacy\` to access the historical Perl workflow.

EOF
