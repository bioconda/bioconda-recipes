#!/bin/bash
set -euo pipefail
cd src && make
cp src/MaxBin $PREFIX/bin/
