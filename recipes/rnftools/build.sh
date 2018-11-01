#! /usr/bin/env bash

set -e
set -o pipefail

PROPHYLE_PACKBIN=1 $PYTHON setup.py install --single-version-externally-managed --record=record.txt
