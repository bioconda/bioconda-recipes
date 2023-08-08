#!/usr/bin/env bash

"$PYTHON" -m site

"$PYTHON" -c 'import hictkpy; print(hictkpy.__version__)'

"$PYTHON" -m pytest test
