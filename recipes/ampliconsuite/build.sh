#!/bin/bash

set -ex

# we have to slightly reorganize the AA src files to make everything work
mv ampliconarchitectlib/src/*.py ampliconarchitectlib/

# add init for ampliconarchitect and ampliconclassifier tools, so they can be imported by AmpliconSuite-pipeline
touch ampliconarchitectlib/__init__.py
touch ampliconclassifierlib/__init__.py

# make the bin dir if it doesn't exist
mkdir -p $PREFIX/bin

# copy driver scripts
# setup.py will handle this in the next release
cp AmpliconSuite-pipeline.py ${PREFIX}/bin/AmpliconSuite-pipeline.py
cp GroupedAnalysisAmpSuite.py ${PREFIX}/bin/GroupedAnalysisAmpSuite.py

# Python command to install the package.
$PYTHON setup.py install --install-data aa_data_repo/ --single-version-externally-managed --record=record.txt
