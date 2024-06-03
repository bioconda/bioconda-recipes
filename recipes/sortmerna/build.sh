#!/usr/bin/env bash

set -x

${PYTHON} setup.py -n all

mkdir -p ${PREFIX}/bin

cp dist/bin/sortmerna ${PREFIX}/bin/
