#!/bin/sh

$PYTHON -m pip install . --ignore-installed --no-deps -vv

cp annotation/*.py ${PREFIX}/bin/
cp bacteria/*.py ${PREFIX}/bin/
cp phasing/[a-zA-Z]*.py ${PREFIX}/bin/
cp phasing/io/[a-zA-Z]*.py ${PREFIX}/bin/
cp post_isoseq_cluster/*.py ${PREFIX}/bin/
cp SequelQC/[a-zA-Z]*.py ${PREFIX}/bin
cp sequence/*.py ${PREFIX}/bin/
cp simulate/*.py ${PREFIX}/bin/
cp targeted/* ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/*
