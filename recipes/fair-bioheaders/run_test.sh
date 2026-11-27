#!/usr/bin/env bash
set -euo pipefail

unset BIOHEADERS_EXPERIMENTAL_FHT
bioheaders-pin-audit --help > /dev/null
bioheaders validate test-data/minimal.fht.json
bioheaders verify test-data/minimal.fht.fasta
BIOHEADERS_EXPERIMENTAL_FHGM=1 BIOHEADERS_FHGM_CONTRACT=0.1 \
    bioheaders verify test-data/minimal.fhgm.gff3 > fhgm-report.txt
grep -F 'FHGM model 0.1: model result: pass' fhgm-report.txt
grep -F 'released FHGFF3 header: pass' fhgm-report.txt
grep -F 'file checksum: verify' fhgm-report.txt
grep -F 'GFF3 feature syntax/biology: not-run' fhgm-report.txt
