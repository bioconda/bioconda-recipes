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
for name in ["testdata/test_input.csv", "testdata/expected_results.csv",
             "assets/licenses.txt", "assets/plotly/plotly.min.js",
             "assets/icons/download.svg", "assets/icons/move.svg",
             "assets/icons/save_figure.svg", "assets/icons/select.svg",
             "assets/icons/table.svg", "assets/icons/zoom-out.svg"]:
    assert package.joinpath(name).is_file(), f"Missing packaged resource: {name}"
PY
dynamic --version
dynamic --help
dynamic test
