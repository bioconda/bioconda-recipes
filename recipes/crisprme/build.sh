#!/bin/bash
set -euo pipefail

# crisprme.py resolves its support tree as <dir-of-crisprme.py>[:-3] + opt/crisprme/,
# so the launcher must land in ${PREFIX}/bin and the source tree in
# ${PREFIX}/opt/crisprme
mkdir -p "${PREFIX}/bin" "${PREFIX}/opt/crisprme"

# Copy every module the CLI and the web app import (PostProcess, seq_script,
# pages, assets, scripts, PAMs, index.py, app.py), excluding bulk test fixtures:
# complete-test and validate-test fetch those over the network at run time and
# only need test/benchmark/benchmarks.json locally
tar -cf - \
    --exclude='./.git' \
    --exclude='./.github' \
    --exclude='./.claude' \
    --exclude='./test/data' \
    --exclude='./test/benchmark/brute-force-*' \
    --exclude='./plot_generation_paper' \
    . | tar -xf - -C "${PREFIX}/opt/crisprme"

cp "${PREFIX}/opt/crisprme/crisprme.py" "${PREFIX}/bin/crisprme.py"
chmod +rx "${PREFIX}/bin/crisprme.py"

chmod -R a+rX "${PREFIX}/opt/crisprme"