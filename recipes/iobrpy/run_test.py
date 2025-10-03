"""
run_test.py — lightweight smoke tests executed by conda-build
- Verifies key packaged data files exist inside iobrpy.resources
- Calls a CLI subcommand with --help to ensure entry points are installed
NOTE: Keep this fast and offline; do not trigger heavy computations.
"""
import importlib.resources as r
import subprocess
import sys

REQUIRED = [
    "anno_eset.pkl",
    "IPS_genes.txt",
    "lm22.txt",
    "c2.cp.kegg.v2023.1.Hs.symbols.gmt",
]

missing = [fn for fn in REQUIRED if not (r.files("iobrpy.resources") / fn).is_file()]
if missing:
    print("Missing packaged resources:", missing)
    sys.exit(1)

# Check one representative CLI command; --help must succeed
subprocess.check_call(["iobrpy", "calculate_sig_score", "--help"])
print("conda recipe smoke test OK")
