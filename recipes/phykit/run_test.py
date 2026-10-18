"""Check the installed package, including commands added by future releases."""

import importlib
from importlib.metadata import distribution
from pathlib import Path
import shutil
import subprocess
import tempfile


entry_points = [
    entry for entry in distribution("phykit").entry_points
    if entry.group == "console_scripts"
]
assert entry_points, "PhyKIT console script metadata is missing"
for entry in entry_points:
    assert shutil.which(entry.name), f"Missing console script: {entry.name}"
    assert callable(entry.load()), f"Invalid console script target: {entry.name}"
    subprocess.run([entry.name, "--help"], check=True, capture_output=True)

# These optional-import paths are not exercised by command-line help.
for module in ("Bio", "numpy", "scipy", "sklearn", "matplotlib", "tqdm", "umap"):
    importlib.import_module(module)

import matplotlib

matplotlib.use("Agg")
from matplotlib import pyplot as plt

with tempfile.TemporaryDirectory() as directory:
    directory = Path(directory)
    tree = directory / "tree.nwk"
    tree.write_text("((A:1,B:1):1,C:1);\n")
    result = subprocess.run(
        ["pk_total_tree_length", str(tree)],
        check=True, capture_output=True, text=True,
    )
    assert float(result.stdout.strip()) == 4.0, result.stdout
    figure, axes = plt.subplots()
    axes.plot([0, 1], [0, 1])
    output = directory / "plot.png"
    figure.savefig(output)
    plt.close(figure)
    assert output.stat().st_size > 0

print(f"Verified {len(entry_points)} console scripts, runtime imports, and plotting")
