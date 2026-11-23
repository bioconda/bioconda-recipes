#!/usr/bin/env bash
set -euo pipefail

eimdl --version | grep -q "hypergrass-eimdl-native"
hypergrass --version | grep -q "HyperGraSS"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
mkdir -p "${TMP_DIR}/panel"

python3 - "${TMP_DIR}" <<'PY'
import hashlib, json, os, subprocess, sys
from pathlib import Path

root = Path(sys.argv[1])
pdir = root / "panel"
seq = (b"ACGT" * 180 + b"TGCA" * 140) * 6
(pdir / "donor0.fa").write_bytes(b">donor0\n" + seq + b"\n")

dna_a = (b"ACGT" * 180 + b"TGCA" * 140) * 3
dna_mid = b"acgtNNNNRY"
dna_b = (b"ACGT" * 180 + b"TGCA" * 140) * 3
target_raw = b">sample_a\r\n" + dna_a + dna_mid + dna_b + b"\r\n"
raw_fa = root / "sample.fa"
raw_fa.write_bytes(target_raw)
expected_sha = hashlib.sha256(target_raw).hexdigest()

arc_n = root / "sample_n.hgs3"
dec_j = root / "sample_from_j.fa"
subprocess.run(["eimdl", "compress-omics", "--target", str(raw_fa), "--out", str(arc_n), "--panel", str(pdir), "--cds", "--threads", "2"], check=True)
subprocess.run(["eimdl-java", "decompress-omics", "--archive", str(arc_n), "--panel", str(pdir), "--out", str(dec_j)], check=True)
assert hashlib.sha256(dec_j.read_bytes()).hexdigest() == expected_sha, "Bioconda Native->Java .hgs3 mismatch"

ana = json.loads(subprocess.check_output(["eimdl", "analyze", "--archive", str(arc_n), "--panel", str(pdir), "--json"], text=True))
assert ana["raw_bytes"] == len(target_raw) and ana["total_bases"] == len(dna_a) + 4 + len(dna_b)
km = json.loads(subprocess.check_output(["eimdl", "kmer", "--archive", str(arc_n), "--panel", str(pdir), "--query", seq[16:37].decode(), "--both-strands", "--json"], text=True))
assert km["hit_count"] >= 1 and km["exact_zero_target_spans"] >= 1
print("PASS: Bioconda eimdl + hypergrass + eimdl-java offline package verification passed.")
PY
