#!/usr/bin/env bash

1>&2 echo "Launching tests..."

"$PYTHON" -c 'import hictkpy; print(hictkpy.__version__)'
"$PYTHON" -m pytest test
