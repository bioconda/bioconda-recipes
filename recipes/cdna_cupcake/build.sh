#!/bin/sh

find . -name *.c -exec rm {} \;
find . -name *.so -exec rm {} \;
$PYTHON -m pip install . --ignore-installed --no-deps -vv

# N.B., not all directories are included, some have files that can't reasonably be reused by anyone.
chmod +x */*.py
cp annotation/*.py ${PREFIX}/bin/
cp phasing/[a-zA-Z]*.py ${PREFIX}/bin/
cp phasing/io/[a-zA-Z]*.py ${PREFIX}/bin/
cp phasing/utils/[a-zA-Z]*.py ${PREFIX}/bin/
cp post_isoseq_cluster/*.py ${PREFIX}/bin/
cp sequence/*.py ${PREFIX}/bin/
cp singlecell/*.py ${PREFIX}/bin/
