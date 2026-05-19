#!/bin/bash
set -euo pipefail

MAIN_SRC="${SRC_DIR}/main_src"

mkdir -p "$PREFIX/bin/beacon2-ri-tools"

# Copy main release contents
cp -r "$MAIN_SRC"/{*.py,ref_schemas,conf,files,validators,pipelines,vrs} \
    "$PREFIX/bin/beacon2-ri-tools/"

# Ensure package recognition
touch "$PREFIX/bin/beacon2-ri-tools/validators/__init__.py"
touch "$PREFIX/bin/beacon2-ri-tools/validators/update/__init__.py"

scripts=(
  "csv_to_bff.py"
  "genomicVariations_vcf.py"
  "genomicVariations_postprocessing.py"
  "individuals_to_cohorts_csv.py"
  "remove_dataset.py"
  "update_record.py"
)

for script in "${scripts[@]}"; do
  WRAPPER="$PREFIX/bin/${script}"

  cat <<EOF > "$WRAPPER"
#!/bin/bash
exec python "\$CONDA_PREFIX/bin/beacon2-ri-tools/${script}" "\$@"
EOF

  chmod +x "$WRAPPER"
  chmod +x "$PREFIX/bin/beacon2-ri-tools/${script}"
done
