#!/usr/bin/env bash
set -euo pipefail

# Source files are available to conda-build tests, but not to mulled containers.
# Keep the full workflow test here; meta.yaml commands test installed tools.
python examples/quickstart/run.py --out quickstart-output
