#!/bin/bash
set -euo

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

export MEDAKA_COMPILE_ARGS="-I${PREFIX}/include"
export MEDAKA_LINK_ARGS="-L${PREFIX}/lib"

# disable Makefile driven build of htslib.a
sed -i.bak "s/'build_ext': HTSBuild//" setup.py

# just link to htslib
sed -i.bak 's/extra_objects.*//' build.py
sed -i.bak 's/^libraries=\[/libraries=\["hts",/' build.py
sed -i.bak 's/-std=c99/-std=c17/' build.py

rm -rf *.bak

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
