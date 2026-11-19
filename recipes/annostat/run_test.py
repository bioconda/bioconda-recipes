"""Exercise installed CDS comparison and its bundled offline report assets."""
import json
from importlib.resources import files
from pathlib import Path
import subprocess
import sys
import tempfile


assets = files("annostat").joinpath("assets")
for name in (
    "gene_report.css", "gene_report.js", "datatables-3.1.4.min.css",
    "datatables-3.1.4.min.js", "datatables-LICENSE.txt",
):
    assert assets.joinpath(name).is_file(), name

with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    fasta = root / "genome.fna"
    fasta.write_text(">chr\nATGAAATAAATGATGAAATAA\n", encoding="utf-8")
    a, b = root / "a.gff3", root / "b.gff3"
    # GFF3 coordinates are 1-based inclusive; the second CDS has a 3-bp start shift.
    a.write_text(
        "##gff-version 3\n"
        "chr\ttest\tCDS\t1\t9\t.\t+\t0\tID=a1;gene=alpha\n"
        "chr\ttest\tCDS\t10\t21\t.\t+\t0\tID=a2;gene=long\n",
        encoding="utf-8",
    )
    b.write_text(
        "##gff-version 3\n"
        "chr\ttest\tCDS\t1\t9\t.\t+\t0\tID=b1;gene=beta\n"
        "chr\ttest\tCDS\t13\t21\t.\t+\t0\tID=b2;gene=short\n",
        encoding="utf-8",
    )
    output = root / "comparison"
    completed = subprocess.run(
        [sys.executable, "-m", "annostat", "compare",
         "--genome", "A", str(fasta), str(a),
         "--genome", "B", str(fasta), str(b),
         "--gene-level", "-o", str(output)],
        check=True, capture_output=True, text=True,
    )
    assert "Accepted CDS pairs" in completed.stdout
    assert "gene-level" in completed.stderr
    result = json.loads((output / "comparison.json").read_text(encoding="utf-8"))
    gene = result["gene_level_comparison"]
    assert gene["coordinate_system"] == "1-based inclusive"
    assert gene["status_counts"] == {"matched": 2}
    assert gene["consequence_counts"] == {"identical": 1, "terminal_only": 1}
    rows = {row["id_a"]: row for row in gene["relationships"]}
    assert rows["a1"]["id_b"] == "b1"
    assert rows["a1"]["relationship"] == "exact"
    assert rows["a2"]["relationship"] == "start_shift"
    assert rows["a2"]["protein_length_delta_aa"] == -1  # B minus A
    for name in ("comparison.html", "comparison.txt", "tables/gene_comparisons.tsv",
                 "plots/gene_consequences.svg"):
        assert (output / name).stat().st_size > 0, name

print("Installed gene comparison, protein evidence, and offline report assets passed.")
