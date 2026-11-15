"""Smoke test of the conda package: no lightmotif, MOODS scans the motifs."""
import importlib.util

import numpy as np

import genomeblocks as gb
from genomeblocks.backends import resolve

# lightmotif is not on conda: the package must work without it
assert importlib.util.find_spec("lightmotif") is None, "lightmotif should not be needed"
assert resolve("motifs") == "moods", resolve("motifs")

# intervals: set algebra on the default (numpy) engine
a = gb.Loci.from_records([("chr1", 100, 200), ("chr1", 500, 900), ("chr2", 10, 50)])
b = gb.Loci.from_records([("chr1", 150, 160), ("chr2", 40, 80)])
assert len(a & b) == 2 and len(a - b) == 1
assert a.to_pandas().shape == (3, 4)

# motifs: a planted ACGTACGT site, found by MOODS, also with a p-value cutoff
rng = np.random.default_rng(0)
seq = "".join(rng.choice(list("ACGT"), 2_000))
seq = seq[:1000] + "ACGTACGT" + seq[1008:]
fasta = {"chr1": seq}
site = np.array([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]] * 2) * 20
L = gb.Loci.from_records([("chr1", 950, 1050), ("chr1", 1450, 1550)])
M = L.scan_motifs_matrix(fasta, {"SITE": site}, r=50, threshold=10.0, norm=False, verbose=False)
assert M.iloc[0, 0] >= 1 and M.iloc[1, 0] == 0, M
P = L.scan_motifs_matrix(fasta, {"SITE": site}, r=50, pvalue=1e-4, norm=False, verbose=False)
assert P.iloc[0, 0] >= 1, P
print("genomeblocks", gb.__version__, "ok:", resolve("motifs"), "scans the motifs")
