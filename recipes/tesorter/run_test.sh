#!/bin/bash
set -euxo pipefail

TEsorter --version
TEsorter2 --version
tesorter2 --version
TEsorter -h > /dev/null
TEsorter2 -h > /dev/null
tesorter2-subset -h > /dev/null

# Functional test without shipping data: the consensus of a bundled REXdb
# profile must come back classified.
python - <<'PY'
import pyhmmer
from tesorter2.paths import get_db_dir
from tesorter2.pipeline import resolve_db
with pyhmmer.plan7.HMMFile(resolve_db("rexdb", db_dir=get_db_dir())) as f:
    for hmm in f:
        name = hmm.name.decode() if isinstance(hmm.name, bytes) else hmm.name
        if "Ty1_copia" in name and name.endswith("-RT"):
            break
with open("consensus.faa", "w") as out:
    out.write(">consensus_{}\n{}\n".format(name.replace("/", "_").replace(":", "_"), hmm.consensus.upper()))
print("emitted", name)
PY
# TEsorter2 with a TEsorter command line, and TEsorter's own pipeline (--legacy).
TEsorter2 consensus.faa -st prot -db rexdb --stages hmmer -dp2 -p 1 -pre out/ts2
test "$(grep -vc '^#' out/ts2.cls.tsv)" -ge 1
TEsorter consensus.faa -st prot -db rexdb --legacy -p 1 -pre out/ts1
test "$(grep -vc '^#' out/ts1.cls.tsv)" -ge 1
