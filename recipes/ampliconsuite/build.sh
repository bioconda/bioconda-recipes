#!/bin/bash

set -ex

# A four-tool AmpliconSuite release is atomic. Never substitute a legacy AC
# source layout or omit BFBA when one of the exact pinned sources cannot be
# installed; fail the package build instead.
if [[ ! -f bfbarchitectlib/pyproject.toml ]]; then
    echo "ERROR: the pinned BFBArchitect source is not independently installable" >&2
    exit 1
fi
if [[ ! -f ampliconclassifierlib/pyproject.toml ]]; then
    echo "ERROR: the pinned AmpliconClassifier source does not support the four-tool package layout" >&2
    exit 1
fi

# we have to slightly reorganize the AA src files to make everything work
mv ampliconarchitectlib/src/*.py ampliconarchitectlib/

# add init for ampliconarchitect, so it can be imported by AmpliconSuite-pipeline
touch ampliconarchitectlib/__init__.py

# Conda supplies Python dependencies. --no-deps prevents pip from replacing
# them while installing the exact BFBA and AC sources embedded in this build.
"$PYTHON" -m pip install --no-deps --no-build-isolation ./bfbarchitectlib
"$PYTHON" -m pip install --no-deps --no-build-isolation ./ampliconclassifierlib

# make the bin dir if it doesn't exist
mkdir -p $PREFIX/bin

# copy driver scripts
# setup.py will handle this in the next release
cp AmpliconSuite-pipeline.py ${PREFIX}/bin/AmpliconSuite-pipeline.py
cp GroupedAnalysisAmpSuite.py ${PREFIX}/bin/GroupedAnalysisAmpSuite.py

# Python command to install the package.
"$PYTHON" setup.py install --install-data aa_data_repo/ --single-version-externally-managed --record=record.txt
