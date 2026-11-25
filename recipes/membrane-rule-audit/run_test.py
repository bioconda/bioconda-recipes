"""Exercise the installed audit package using only its runtime dependencies."""

import importlib.metadata
import os

import numpy as np

from membrane_rule_audit import panel

version = importlib.metadata.version("membrane-rule-audit")
if os.environ.get("PKG_VERSION"):
    assert version == os.environ["PKG_VERSION"], (version, os.environ["PKG_VERSION"])

scores = np.full((4, 20), np.nan)
scores[:, panel.ALPHABET.index("N")] = 0.1
for alternate in "KR":
    scores[:, panel.ALPHABET.index(alternate)] = [0.2, 0.5, 0.2, 0.5]
inputs = {
    "scores": scores,
    "protein": np.array([0, 0, 1, 1]),
    "ref_aa": np.full(4, panel.ALPHABET.index("A")),
    "side": np.array([0, 1, 0, 1]),
}
contrast = panel.gain_contrast(inputs)
parts = panel.stratum_parts(inputs, contrast["penalty"], contrast["eligible"])
result = panel.summarize_parts(parts, draws=0, seed=7)
assert abs(result["estimate_raw"] + 0.30) < 1e-12, result
assert result["n_proteins"] == 2, result
assert result["n_contributing_sites"] == 4, result
print(f"Installed {version}: audit smoke computation passed")

