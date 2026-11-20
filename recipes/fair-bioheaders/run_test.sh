#!/usr/bin/env bash
set -euo pipefail

unset BIOHEADERS_EXPERIMENTAL_FHT BIOHEADERS_CANDIDATE_FHT
bioheaders-pin-audit --help > /dev/null
bioheaders validate test-data/minimal.fht.json
bioheaders verify test-data/minimal.fht.fasta
BIOHEADERS_EXPERIMENTAL_FHGM=1 BIOHEADERS_FHGM_CONTRACT=0.1 \
    bioheaders verify test-data/minimal.fhgm.gff3 > fhgm-report.txt
grep -F 'FHGM model 0.1: model result: pass' fhgm-report.txt
grep -F 'released FHGFF3 header: pass' fhgm-report.txt
grep -F 'file checksum: verify' fhgm-report.txt
grep -F 'GFF3 feature syntax/biology: not-run' fhgm-report.txt

python - <<'PY'
import hashlib
import json
from importlib.resources import files
from pathlib import Path
from bioheaders import selection

provenance = json.loads(Path('test-data/provenance.json').read_text())
for row in provenance['files']:
    data = (Path('test-data') / row['file']).read_bytes()
    assert len(data) == row['bytes']
    assert hashlib.sha256(data).hexdigest() == row['sha256']
entry = selection.BUNDLED['modelContracts']['FHGM']
assert entry['modelContractVersion'] == '0.1'
assert 'FHGM' not in selection.BUNDLED['current']['files']
record = entry['files']['record']
data = files('bioheaders').joinpath(record['file']).read_bytes()
assert hashlib.sha256(data).hexdigest() == '56c0a5a91e9e56c50c0919a375505c01f52bce5f1792841c40b87b1cd18e9336'
PY
