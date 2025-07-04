#!/usr/bin/env bash
set -euxo pipefail


cat << EOF > setup.py
from setuptools import setup, find_packages

setup(
    name="kmetashot",
    version="${PKG_VERSION}",   #  0.1.0
    packages=find_packages(),
    install_requires=[
        "numpy",
        "pandas",
        "h5py",
        "argcomplete"
    ],
    entry_points={
        "console_scripts": [
            "kmetashot=kMetaShot_package.kMetaShot_classifier_NV:main"
        ]
    },
    author="Giuseppe Defazio",
    license="GPL-3.0-only",
    url="https://github.com/LuigiMansi1/kMetaShot",
    description="Fast taxonomic classifier per metagenome bins basato su k-mer/minimizer",
)
EOF

$PYTHON -m pip install . --no-deps -vv

