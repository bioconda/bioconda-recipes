#!/bin/bash
set -exo pipefail

# Copy all source files from SRC_DIR into the bin folder
mkdir -p "$PREFIX/bin/beacon2-ri-tools/"
cp -r "$SRC_DIR"/{*.py,scripts,ref_schemas,conf,files,validators} "$PREFIX/bin/beacon2-ri-tools/"

# List of python script names
scripts=("analyses_csv.py" "biosamples_csv.py" "cohorts_csv.py" "convert_csvTObff.py" "datasets_csv.py" "genomicVariations_csv.py" "genomicVariations_postprocessing.py" "genomicVariations_vcf.py" "individuals_csv.py" "individuals_to_cohorts_csv.py" "remove_dataset.py" "runs_csv.py" "update_record.py")

# Loop through each script name
for script in "${scripts[@]}"; do
  # Define the wrapper script path
  WRAPPER="$PREFIX/bin/${script}"
  cat > "$WRAPPER" <<EOF
#!/bin/bash
# wrapper: change to the install dir so relative file paths inside scripts work
cd "\$CONDA_PREFIX/bin/beacon2-ri-tools" || exit 1
exec "\$PYTHON" "\$CONDA_PREFIX/bin/beacon2-ri-tools/${script}" "\$@"
EOF

  # Make the wrapper and the original python script executable
  chmod +x "$WRAPPER"
  chmod +x "$PREFIX/bin/beacon2-ri-tools/${script}"
done
