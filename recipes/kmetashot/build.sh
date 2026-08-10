#!/usr/bin/env bash
set -euxo pipefail

cat << EOF > setup.py
from setuptools import setup

setup(
    name="kmetashot",
    version="${PKG_VERSION}",   #  2.0
    packages=['kMetaShot_package'],
    scripts=['kMetaShot_classifier_NV.py', 'kMetaShot_test.py'],
    author="Giuseppe Defazio",
    license="GPL-3.0-only",
    url="https://github.com/gdefazio/kMetaShot",
    description="Fast taxonomic classifier for metagenome bins/MAGs based on k-mer/minimizer",
)
EOF

$PYTHON -m pip install . --no-deps -vv

