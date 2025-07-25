#!/bin/bash

rm -f lib/psyco_full.py
rm -rf data test

${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation
