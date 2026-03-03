#!/bin/bash
set -euo pipefail

# Create installation directory inside conda prefix
mkdir -p "$PREFIX/bin/beacon2-ri-tools"

# Copy required project structure
cp -r "$SRC_DIR"/{*.py,ref_schemas,conf,files,validators} \
    "$PREFIX/bin/beacon2-ri-tools/"

# Ensure package recognition
touch "$PREFIX/bin/beacon2-ri-tools/validators/__init__.py"

# List of supported v2 entrypoints
scripts=(
  "csv_to_bff.py"
  "genomicVariations_vcf.py"
  "genomicVariations_postprocessing.py"
  "individuals_to_cohorts_csv.py"
  "remove_dataset.py"
  "update_record.py"
)

# Create wrapper scripts
for script in "${scripts[@]}"; do
  WRAPPER="$PREFIX/bin/${script}"

  cat <<EOF > "$WRAPPER"
#!/bin/bash
cd "\$CONDA_PREFIX/bin/beacon2-ri-tools"
exec python "./${script}" "\$@"
EOF

  chmod +x "$WRAPPER"
  chmod +x "$PREFIX/bin/beacon2-ri-tools/${script}"
done
