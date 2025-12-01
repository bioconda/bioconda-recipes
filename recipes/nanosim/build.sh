#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
cp -rf src/*.py ${PREFIX}/bin/
cp -rf src/*lua ${PREFIX}/bin/

chmod 0755 "${PREFIX}/bin/read_analysis.py"
chmod 0755 "${PREFIX}/bin/simulator.py"
