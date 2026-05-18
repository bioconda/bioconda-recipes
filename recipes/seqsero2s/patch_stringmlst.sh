#!/usr/bin/env bash

# patch stringMLST.py log path: replace dbPrefix reference with cwd.
# patches all occurrences (at line 1464 and predict section at line 1478).

set -euo pipefail

STRINGMLST="$PREFIX/bin/stringMLST.py"

if [ ! -f "$STRINGMLST" ]; then
    echo "SKIP: $STRINGMLST not found"
    exit 0
fi

python3 << 'PATCH_WITH_PY'
import os

p = os.path.join(os.environ["PREFIX"], "bin", "stringMLST.py")
with open(p) as f:
    lines = f.readlines()

original = "            log = dbPrefix+'.log'\n"
commented = "            # log = dbPrefix+'.log'\n"
replacement = '            log = os.path.join(os.getcwd(), "kmer.log")\n'

# Count occurrences BEFORE modifying
occurrences = lines.count(original)

if occurrences == 0:
    print("SKIP: stringMLST.py has 0 occurrences, expected at least 1")
    exit(0)

out = []
for line in lines:
    if line.rstrip("\n") == original.rstrip("\n"):
        out.append(commented)
        out.append(replacement)
    else:
        out.append(line)

with open(p, "w") as f:
    f.writelines(out)

print("PATCHED: stringMLST.py log path fixed (%d occurrences)" % occurrences)
PATCH_WITH_PY