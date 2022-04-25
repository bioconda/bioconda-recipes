#!/usr/bin/env python

from pathlib import Path
from subprocess import run, PIPE, STDOUT

import pangolin

test_data = Path(pangolin.__file__).parent / 'data/reference.fasta'
cmd = ['pangolin', str(test_data)]
pangolin_proc = run(cmd, stdout=PIPE, stderr=STDOUT)
assert b'Output file written to' in pangolin_proc.stdout, pangolin_proc.stdout
