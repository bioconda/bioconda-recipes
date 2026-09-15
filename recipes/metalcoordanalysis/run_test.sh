#!/bin/bash
set -exo pipefail

metalCoord stats -p tests/data/models/3kw8.cif -l CU -o /tmp/cu_test.json
metalCoord stats -p tests/data/models/4dl8.cif -l MG -o /tmp/mg_test.json
metalCoord stats -p tests/data/models/4dl8.cif -l NA -o /tmp/na_test.json
metalCoord update -i tests/data/dicts/SF4.cif -p 5d8v -o /tmp/SF4_updated.cif
