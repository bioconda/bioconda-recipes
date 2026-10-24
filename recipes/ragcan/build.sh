#!/bin/bash
set -euo pipefail

# RaGCAn is a single self-contained script with a shebang. Installing it means
# putting it on PATH and making it executable. Nothing to compile.
mkdir -p "${PREFIX}/bin"
cp RaGCAn.py fast_aai.py run_fast.py "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/RaGCAn.py" "${PREFIX}/bin/run_fast.py"
