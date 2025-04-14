#!/usr/bin/env python

from pathlib import Path
from subprocess import run, PIPE, STDOUT
import sys

import pangolin

test_data = Path(pangolin.__file__).parent / 'data/reference.fasta'
cmd = ['pangolin', str(test_data)]
pangolin_proc = run(cmd, stdout=PIPE, stderr=STDOUT)
print(pangolin_proc.stdout.decode(), file=sys.stderr)
assert b'Output file written to' in pangolin_proc.stdout
