#!/usr/bin/env bash

1>&2 echo "Launching tests..."

sleep 30  # Give the runner a chance to pickup echo's output

"$PYTHON" -c 'import hictkpy; print(hictkpy.__version__)'
"$PYTHON" -m pytest test
