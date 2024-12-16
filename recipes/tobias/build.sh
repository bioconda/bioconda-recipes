#!/bin/bash

cp -rf ${RECIPE_DIR}/setup.py .

${PYTHON} -m pip install --no-deps --no-build-isolation --no-cache-dir --use-pep517 . -vvv
