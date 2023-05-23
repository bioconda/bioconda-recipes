#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"

export CFLAGS="-I${PREFIX}/include ${LDFLAGS}"

# disable Makefile driven build of htslib.a
sed -i.bak "s/'build_ext': HTSBuild//" setup.py

# just link to htslib
sed -i.bak 's/extra_objects.*//' build.py
sed -i.bak 's/^libraries=\[/libraries=\["hts",/' build.py

$PYTHON -m pip install . -vv
