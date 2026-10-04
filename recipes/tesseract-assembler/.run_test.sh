#!/usr/bin/env bash
# conda-build package test.
#
# The command tests in meta.yaml prove the binaries exist and still carry the flags a
# pipeline may have been built against. This proves the thing actually assembles, which is
# the only claim that matters and the one a broken compiler flag or a mislinked zlib would
# silently break.
#
# A 6 kb random genome sequenced at even coverage: unambiguous, so a working assembler must
# return it in a single contig. Small enough that the test costs a couple of seconds.
set -euo pipefail

python - <<'PY'
import random
random.seed(7)
g = "".join(random.choice("ACGT") for _ in range(6000))
with open("g.fa", "w") as fh:
    fh.write(">g\n" + g + "\n")

def rc(s):
    return s[::-1].translate(str.maketrans("ACGT", "TGCA"))

read, ins = 100, 300
with open("r1.fq", "w") as a, open("r2.fq", "w") as b:
    for i, p in enumerate(range(0, len(g) - ins, 3)):
        a.write("@r%d/1\n%s\n+\n%s\n" % (i, g[p:p + read], "I" * read))
        b.write("@r%d/2\n%s\n+\n%s\n" % (i, rc(g[p + ins - read:p + ins]), "I" * read))
PY

tesseract-asm -1 r1.fq -2 r2.fq -o testasm -t 2

test -s testasm/contigs.fasta

# One contig, and its length within a k of the truth. Assembling a unique 6 kb sequence into
# several pieces means something is wrong that --version would never reveal.
n=$(grep -c '^>' testasm/contigs.fasta)
len=$(grep -v '^>' testasm/contigs.fasta | tr -d '\n' | wc -c)
echo "assembled $n contig(s), $len bp (expected 1 contig, about 6000 bp)"
[ "$n" -eq 1 ] || { echo "expected a single contig, got $n" >&2; exit 1; }
[ "$len" -ge 5500 ] && [ "$len" -le 6200 ] || { echo "length $len is not near 6000" >&2; exit 1; }

# Flag checks, from help captured once. A flag that silently disappears is worse than one
# that was never there: a pipeline built against it breaks with no explanation.
tesseract-asm --help > tesseract_help.txt
tesseract-model --help > model_help.txt
for f in --organism --model --is-panel --map-polish; do
    grep -q -- "$f" tesseract_help.txt || { echo "tesseract-asm --help lost $f" >&2; exit 1; }
done
grep -q -- --marker-density model_help.txt || { echo "tesseract-model --help lost --marker-density" >&2; exit 1; }
echo "help lists every expected flag"

echo "package test passed"
