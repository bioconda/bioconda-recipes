#! /usr/bin/env bash

set -e
set -o pipefail

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
prophyle compile
