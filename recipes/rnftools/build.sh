#! /usr/bin/env bash

set -e
set -o pipefail

$PYTHON setup.py install -vvv --single-version-externally-managed --record=record.txt
