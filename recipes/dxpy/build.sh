#!/bin/bash

set -eu -o pipefail

#sed -i.bak 's/==/>=/' requirements.txt
$PYTHON -m pip install . --no-deps --ignore-installed -vv 

