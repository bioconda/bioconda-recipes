#!/usr/bin/env python

from pathlib import Path
from subprocess import run, PIPE, STDOUT

import pangolin

test_data = Path(pangolin.__file__).parent / 'data/reference.fasta'
refseq = open(test_data).read()

# usher 0.6.1 hangs on input with no mutations
# see https://github.com/cov-lineages/pangolin/issues/500
# so we need to engineer suitable test input.
with open('tmp.fa', 'w') as o:
    o.write(refseq.replace('ACATGGTTTAGTCAGCGTGG', 'ACATGGTTTAGCCAGCGTGG'))
cmd = ['pangolin', 'tmp.fa']
pangolin_proc = run(cmd, stdout=PIPE, stderr=STDOUT)
assert b'Output file written to' in pangolin_proc.stdout, pangolin_proc.stdout
