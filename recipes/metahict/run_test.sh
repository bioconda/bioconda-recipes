#!/usr/bin/env bash
set -euo pipefail

installed_root="${PREFIX}/share/metahict"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/metahict-bioconda-test.XXXXXX")"
trap 'rm -rf "${test_root}"' EXIT

dummy_db="${test_root}/dummy_db"
mkdir -p \
  "${dummy_db}/checkm_db" \
  "${dummy_db}/gtdbtk_db" \
  "${dummy_db}/genomad_db" \
  "${test_root}/reports"
touch "${dummy_db}/checkm2.dmnd"
stub_samplesheet="$(python "${installed_root}/nextflow/ci/create_stub_inputs.py" \
  --output-dir "${test_root}/stub_inputs")"

metahict-nextflow \
  -profile stub \
  -c "${installed_root}/nextflow/nextflow.config" \
  -c "${installed_root}/nextflow/ci/stub_resources.config" \
  --samplesheet "${stub_samplesheet}" \
  --out_root "${test_root}/results" \
  --report_dir "${test_root}/reports" \
  -work-dir "${test_root}/work" \
  --checkm_db "${dummy_db}/checkm_db" \
  --checkm2_db "${dummy_db}/checkm2.dmnd" \
  --gtdbtk_db "${dummy_db}/gtdbtk_db" \
  --genomad_db "${dummy_db}/genomad_db" \
  --threads 2 \
  --clean true \
  --chain true \
  -stub-run \
  -ansi-log false

python "${installed_root}/nextflow/bin/check_expected_outputs.py" \
  --root "${test_root}/results" \
  --manifest "${installed_root}/nextflow/tests/expected/workflow_stub_outputs.tsv"
