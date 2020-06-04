#!/bin/bash
set -euxo pipefail

mkdir -p ${PREFIX}/bin/
"$PYTHON" -m pip install --ignore-installed -vv .
chmod +x *.py
mv phanotate.py ${PREFIX}/bin/phanotate
