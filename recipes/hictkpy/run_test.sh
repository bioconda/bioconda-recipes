#!/usr/bin/env bash

"$PYTHON" -c 'import hictkpy; print(hictkpy.__version__)'
"$PYTHON" -m pytest test -v
