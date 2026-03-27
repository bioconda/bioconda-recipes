#!/bin/bash
set -exo pipefail

metalCoord stats -p tests/data/models/3kw8.cif -l CU -o /tmp/cu_test.json --no-progress
metalCoord stats -p tests/data/models/4dl8.cif -l MG -o /tmp/mg_test.json --no-progress
metalCoord stats -p tests/data/models/4dl8.cif -l NA -o /tmp/na_test.json --no-progress
metalCoord update -i tests/data/dicts/8tnv.cif -o /tmp/8tnv_updated.cif --no-progress
