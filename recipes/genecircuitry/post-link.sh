#!/bin/bash
# post-link.sh — runs automatically after `conda install genecircuitry`.
# Note: Do not install pip-only dependencies here; this must remain offline/reproducible.
set -euo pipefail

PYTHON_BIN="${PREFIX}/bin/python"

echo "==> [genecircuitry post-link] Skipping automatic installation of pip-only dependencies."
echo "    The packages 'celloracle==0.18.0' and 'hotspotsc==1.1.3' are not installed"
echo "    automatically by this conda package in order to keep installs"
echo "    offline-capable and reproducible."
echo
echo "If you need functionality that depends on these packages, please install them"
echo "manually in the active environment, for example:"
echo "    pip install 'celloracle==0.18.0' 'hotspotsc==1.1.3'"
echo
echo "==> [genecircuitry post-link] Done."
