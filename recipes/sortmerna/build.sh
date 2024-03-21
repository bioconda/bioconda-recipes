#!/usr/bin/env bash

set -x

python setup.py -n all

mkdir -p ${PREFIX}/bin

cp dist/bin/sortmerna ${PREFIX}/bin/
