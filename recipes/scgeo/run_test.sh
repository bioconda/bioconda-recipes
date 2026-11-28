#!/usr/bin/env bash
set -euo pipefail
export MPLBACKEND=Agg
export PYTHONNOUSERSITE=1

# These checks use test-only dependencies, so they belong here rather than
# in meta.yaml commands, which Bioconda also runs in its runtime-only container.
python -m pip check
python scripts/smoke_installation.py
