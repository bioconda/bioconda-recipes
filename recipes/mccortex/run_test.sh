#!/bin/bash
set -euo pipefail
# mccortex does not have a simple --help or --version option that
# would allow running it to get an exit code of 0.
echo -e '>1\nAAA' > test.fa
mccortex 31 build -k 5 --sample test_sample -1 test.fa test.ctx > /dev/null

# but I suppose we can get around that by greping for usage
# let's make sure to check both k-mer sizes were compiled
set +o pipefail
mccortex 31 2>&1 | grep -F 'usage: mccortex31 <command> [options] <args>' > /dev/null
mccortex 63 2>&1 | grep -F 'usage: mccortex63 <command> [options] <args>' > /dev/null
mccortex 95 2>&1 | grep -F 'usage: mccortex95 <command> [options] <args>' > /dev/null
mccortex 127 2>&1 | grep -F 'usage: mccortex127 <command> [options] <args>' > /dev/null
set -o pipefail
