#!/usr/bin/env bash
set -euxo pipefail

${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

mkdir -p "${PREFIX}/share/phads"
cp -R scripts "${PREFIX}/share/phads/"
cp -R database "${PREFIX}/share/phads/"
