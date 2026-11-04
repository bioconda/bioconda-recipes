#!/usr/bin/env bash
set -euo pipefail

mkdir -p .scratch/tmp
export TMPDIR="$PWD/.scratch/tmp"
cat > "$TMPDIR/input.fq" <<'FASTQ'
@good
ACGT
+
IIII
@reject
NNNN
+
IIII
FASTQ
head -n 4 "$TMPDIR/input.fq" > "$TMPDIR/expected.fq"
SOAPnuke process --r1 "$TMPDIR/input.fq" --out1 "$TMPDIR/clean.fq" \
  --report "$TMPDIR/report.json" --threads 2 -n 0.05
cmp "$TMPDIR/expected.fq" "$TMPDIR/clean.fq"
test -s "$TMPDIR/report.json"
