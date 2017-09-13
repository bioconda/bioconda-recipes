#! /usr/bin/env bash

set -e
set -o pipefail

ls
find .

make
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
