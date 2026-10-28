#!/bin/bash
set -exo pipefail

# Copy all source files from SRC_DIR into the bin folder
mkdir -p "$PREFIX/bin/clincnv/"
cp -r "$SRC_DIR"/{*.R,germline,somatic,PCAWG,helper_scripts,trios} "$PREFIX/bin/clincnv/"

# List of R script names
scripts=("clinCNV.R" "mergeFilesFromFolder.R" "mergeFilesFromFolderDT.R")

# Loop through each script name
for script in "${scripts[@]}"; do
  # Define the wrapper script path
  WRAPPER="$PREFIX/bin/${script}"

  # Create the wrapper script
  echo '#!/bin/bash' > "$WRAPPER"
  echo "Rscript \"\$CONDA_PREFIX/bin/clincnv/${script}\" \"\$@\"" >> "$WRAPPER"

  # Make the wrapper and the original R script executable
  chmod +x "$WRAPPER"
  chmod +x "$PREFIX/bin/clincnv/${script}"
done
