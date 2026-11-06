"""Exercise installed NASP resource lookup, matrix generation, exports and filters."""

import csv
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from unittest.mock import patch

import nasp.nasp as nasp
import nasp.dispatcher as dispatcher


def run(*args):
    return subprocess.run(args, check=True, capture_output=True, text=True).stdout


assert Path(nasp.gonasp_path()).is_file()
with patch.object(nasp, "_get_java_path", return_value="trimmomatic.jar"), \
        patch.object(nasp, "_get_advanced_settings", side_effect=lambda *args: args), \
        patch("builtins.input", side_effect=["", "", ""]):
    settings = nasp._get_trimming_parameters("", "")
    adapter = settings[2].split("ILLUMINACLIP:", 1)[1].split(":4:", 1)[0]
    assert Path(adapter).is_file()

original_cwd = Path.cwd()
with tempfile.TemporaryDirectory() as directory:
    os.chdir(directory)
    reference = Path("reference.fasta")
    reference.write_text(">chr1\nACGTACGT\n")
    Path("sample.frankenfasta").write_text(">franken::chr1\nACGTTCGT\n")
    Path("matrices").mkdir()
    Path("statistics").mkdir()
    run("nasp", "matrix", "--reference-fasta", str(reference), "--matrix-folder",
        "matrices", "--stats-folder", "statistics", "sample.frankenfasta")
    matrix = Path("matrices/bestsnp.tsv")
    with matrix.open() as handle:
        rows = list(csv.DictReader(handle, delimiter="\t"))
    assert len(rows) == 1, rows
    assert rows[0]["Position"] == "5" and rows[0]["Reference"] == "A"
    assert rows[0]["sample"] == "T", rows
    fasta = run("nasp", "export", "--type", "fasta", str(matrix))
    assert fasta.splitlines() == [">Reference", "A", ">sample", "T"], fasta
    vcf = run("nasp", "export", "--type", "vcf", str(matrix))
    assert "chr1\t5\t" in vcf, vcf
    Path("genomes.txt").write_text("Reference\nsample\n")
    run("filter_matrix_by_genome.py", "-m", str(matrix), "-p", "kept",
        "-g", "genomes.txt", "-a", "keep")
    assert Path("kept_genomes.matrix").read_text() == matrix.read_text()
    run("filter_matrix_by_distance.py", "-m", str(matrix), "-r", str(reference),
        "-p", "spaced", "-d", "2")
    assert Path("spaced_distance_filtered.matrix").read_text() == matrix.read_text()
    assert ">sample" in Path("spaced_distance_filtered.fasta").read_text()
    os.chdir(original_cwd)

# Exercise the actual installed dispatcher with the recipe's external tools.
# This detects both an absent dependency and the obsolete view -ceg API.
with tempfile.TemporaryDirectory() as directory:
    work = Path(directory)
    reference = work/"reference.fasta"
    reference.write_text(">chr1\nACGTACGT\n")
    sam = work/"input.sam"
    sam.write_text("@HD\tVN:1.0\tSO:coordinate\n@SQ\tSN:chr1\tLN:8\n" + "".join(
        "read%d\t0\tchr1\t1\t60\t8M\t*\t0\t0\tACGTACGT\tIIIIIIII\n" % i
        for i in range(12)))
    samtools = shutil.which("samtools")
    bcftools = shutil.which("bcftools")
    assert samtools and bcftools
    assert run(samtools, "--version").splitlines()[0] == "samtools 1.3.1"
    run(samtools, "faidx", str(reference))
    with (work/"unsorted.bam").open("wb") as output:
        subprocess.run([samtools, "view", "-bS", str(sam)], stdout=output, check=True)
    # Exercise the sort interface required by the adapted dispatchers.
    run(samtools, "sort", "-o", str(work/"sorted.bam"), str(work/"unsorted.bam"))
    bam = work/"sorted.bam"
    run(samtools, "index", str(bam))

    def submit_locally(submitter, command, parameters, dependencies):
        subprocess.run(["bash", "-o", "pipefail", "-c", command], check=True,
                       capture_output=True, text=True)
        return "local-api-test"

    with patch.object(dispatcher, "_submit_job", side_effect=submit_locally):
        _, _, output = dispatcher._run_samtools("sample", str(bam),
            ("SAMtools", bcftools, "", {}), ("SAMtools", samtools, "", {}),
            "local", "input-ready", str(reference), str(work))
    lines = Path(output).read_text().splitlines()
    assert any(line.startswith("#CHROM\t") for line in lines)
    assert len([line for line in lines if not line.startswith("#")]) == 8

print("NASP installed-package smoke tests passed on Python", sys.version.split()[0])

"""Check package ownership, relocation, tool discovery and Java entry points."""
import json
import os
from pathlib import Path
import subprocess
import sys
from unittest.mock import patch

from nasp.nasp import _get_java_path

prefix = Path(sys.prefix)
assert sys.version_info >= (3, 11)
expected = {
    "GenomeAnalysisTK.jar": "../opt/gatk-3.8/GenomeAnalysisTK.jar",
    "picard.jar": "../share/picard-2.27.5-0/picard.jar",
    "VarScan.jar": "../share/varscan-2.4.6-0/VarScan.jar",
    "trimmomatic.jar": "../share/trimmomatic-0.40-0/trimmomatic.jar",
    "snap_aligner": "snap-aligner",
}
records = {r["name"]: r for r in map(lambda p: json.loads(p.read_text()),
                                   (prefix / "conda-meta").glob("*.json"))}
assert "java-jdk" not in records
for name, target in expected.items():
    link = prefix / "bin" / name
    assert link.is_symlink(), link
    assert os.readlink(link) == target, (link, os.readlink(link))
    assert link.is_file(), (link, "broken target")
    assert link.resolve().is_relative_to(prefix.resolve()), link
    if name.endswith(".jar"):
        with patch("builtins.input", side_effect=AssertionError("Unexpected path prompt")):
            found = _get_java_path(name)
        assert Path(found).resolve() == link.resolve(), (name, found)

java = str(prefix / "bin/java")
checks = [
    ([java, "-version"], (0,), "1.8.0_"),
    ([java, "-jar", str(prefix / "bin/GenomeAnalysisTK.jar"), "--version"], (0,), "3.8"),
    ([java, "-jar", str(prefix / "bin/picard.jar"), "CreateSequenceDictionary", "--version"], (0, 1), "2.27.5"),
    ([java, "-jar", str(prefix / "bin/VarScan.jar")], (0, 1), "VarScan"),
    ([java, "-jar", str(prefix / "bin/trimmomatic.jar"), "-version"], (0,), "0.40"),
    ([str(prefix / "bin/snap_aligner")], (0, 1), "SNAP"),
]
for command, codes, marker in checks:
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, timeout=120)
    assert result.returncode in codes, (command, result.returncode, result.stdout)
    assert marker.lower() in result.stdout.lower(), (command, result.stdout)
print(json.dumps({"status": "passed", "links": expected, "entry_points": len(checks)}))
