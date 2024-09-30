#!/bin/bash -euo

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"

# disable Makefile driven build of htslib.a
sed -i.bak "s/'build_ext': HTSBuild//" setup.py

# just link to htslib
sed -i.bak 's/extra_objects.*//' build.py
sed -i.bak 's/^libraries=\[/libraries=\["hts",/' build.py

rm -rf *.bak

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
