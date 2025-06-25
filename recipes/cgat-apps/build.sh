#!/bin/bash

# export compiler flags
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"

# remove install_requires (no longer required with conda package)
sed -i.bak'' -e '/REPO_REQUIREMENT/,/pass/d' setup.py
sed -i.bak'' -e '/# dependencies/,/dependency_links=dependency_links,/d' setup.py
rm -rf *.bak

# https://bioconda.github.io/linting.html#setup-py-install-args
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
