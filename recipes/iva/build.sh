#!/bin/bash

set -euf -o pipefail

$PYTHON setup.py install  --single-version-externally-managed --record=record.txt
