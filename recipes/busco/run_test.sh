#!/bin/bash

set -euo pipefail

(generate-busco-config.py -h | grep "usage:") || exit 1

# The directory in which generate-busco-config.py is stored should itself be
# found in the "path = " lines of its output
d=$(dirname $(which generate-busco-config.py))
(generate-busco-config.py | grep "path = " | grep $d) || exit 1
