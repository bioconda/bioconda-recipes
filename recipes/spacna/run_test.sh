#!/usr/bin/env bash
# Optional bioconda test script (meta.yaml test.commands is usually enough).
set -euo pipefail

spacna help
spacna path
test -d "$(spacna path)/scripts"
test -d "$(spacna path)/reference"
python -c "import pysam, natsort, pandas, numpy"
