#!/bin/bash
set -euo pipefail
cp makefile.new src
cd src && make -f makefile.new
cp MaxBin $PREFIX/bin/
