#!/bin/bash
set -ex

make -j ${CPU_COUNT}
mkdir -p ${PREFIX}/bin
install -v -m 755 bin/taffy ${PREFIX}/bin/

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir