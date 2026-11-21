#!/usr/bin/env bash
set -euo pipefail
unset PYTHONPATH
export PYTHONDONTWRITEBYTECODE=1
export MPLBACKEND=Agg
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
test_dir=$(mktemp -d)
export MPLCONFIGDIR="$test_dir/matplotlib"
cd "$test_dir"
python - <<'PY'
from importlib import resources

package = resources.files("dynamic")
for name in ["assets/licenses.txt", "assets/plotly/plotly.min.js"]:
    assert package.joinpath(name).is_file(), f"Missing packaged resource: {name}"

icons = package.joinpath("assets/icons")
assert any(icon.is_file() for icon in icons.iterdir()), "No packaged icons found"
PY
dynamic --version
dynamic --help
dynamic test
