#!/bin/bash
set -euo pipefail
# None of the three commands have a simple --help or --version option that
# would allow to run them and get an exit code of 0.
echo -e '1\t2\t3' > test.bed
bgzip test.bed
tabix test.bed.gz
htsfile test.bed.gz > /dev/null
