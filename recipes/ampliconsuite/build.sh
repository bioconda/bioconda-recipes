#!/bin/bash

set -ex

# we have to slightly reorganize the AA src files to make everything work
mv ampliconarchitectlib/src/*.py ampliconarchitectlib/

# add init for ampliconarchitect, so it can be imported by AmpliconSuite-pipeline
touch ampliconarchitectlib/__init__.py

# make the bin dir if it doesn't exist
mkdir -p $PREFIX/bin

# copy driver scripts
# setup.py will handle this in the next release
cp AmpliconSuite-pipeline.py ${PREFIX}/bin/AmpliconSuite-pipeline.py
cp GroupedAnalysisAmpSuite.py ${PREFIX}/bin/GroupedAnalysisAmpSuite.py
cp amplicon_classifier.py ${PREFIX}/bin/amplicon_classifier.py
cp feature_similarity.py ${PREFIX}/bin/feature_similarity.py
cp make_results_table.py ${PREFIX}/bin/make_results_table.py
cp make_input.sh ${PREFIX}/bin/make_input.sh

# Python command to install the package.
$PYTHON setup.py install --install-data aa_data_repo/ --single-version-externally-managed --record=record.txt
