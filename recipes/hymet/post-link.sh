#!/bin/bash

cat > "$PREFIX/.messages.txt" << EOF

Thank you for installing HYMET (Hybrid Metagenomic Tool)!

Before you can use HYMET, you need to download the required reference databases:

1. Download these files from Google Drive:
   - sketch1.msh.gz
   - sketch2.msh.gz
   - sketch3.msh.gz
   
   Link: https://drive.google.com/drive/folders/1YC0N77UUGinFHNbLpbsucu1iXoLAM6lm

2. Place these files in the data directory:
   $PREFIX/bin/data/

3. Unzip the files:
   gunzip $PREFIX/bin/data/sketch1.msh.gz
   gunzip $PREFIX/bin/data/sketch2.msh.gz
   gunzip $PREFIX/bin/data/sketch3.msh.gz

4. Run the configuration script to set up taxonomy files:
   hymet-config

Now you can use HYMET with the 'hymet' command!

EOF 