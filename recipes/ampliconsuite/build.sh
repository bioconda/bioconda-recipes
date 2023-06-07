#!/bin/bash

# pull source code for AA and move scripts into a library
TARGET="AmpliconArchitect"
TARGET_VERSION="1.3.r5"
wget https://github.com/AmpliconSuite/${TARGET}/archive/refs/tags/v${TARGET_VERSION}.zip
unzip v${TARGET_VERSION}.zip
mkdir -p ampliconarchitectlib
cp ${TARGET}-${TARGET_VERSION}/src/*.py ampliconarchitectlib/
touch ampliconarchitectlib/__init__.py
rm v${TARGET_VERSION}.zip

# pull source code for AC and move scripts into a library
TARGET="AmpliconClassifier"
TARGET_VERSION="0.5.2"
wget https://github.com/AmpliconSuite/${TARGET}/archive/refs/tags/v${TARGET_VERSION}.zip
unzip v${TARGET_VERSION}.zip
mkdir -p ampliconclassifierlib
cp ${TARGET}-${TARGET_VERSION}/*.py ampliconclassifierlib/
cp ${TARGET}-${TARGET_VERSION}/*.sh ampliconclassifierlib/
cp -r ${TARGET}-${TARGET_VERSION}/resources/ ampliconclassifierlib/resources/
touch ampliconclassifierlib/__init__.py
rm v${TARGET_VERSION}.zip

# make the bin dir if it doesn't exist
mkdir -p $PREFIX/bin

# copy driver scripts
cp AmpliconSuite-pipeline.py ${PREFIX}/bin/AmpliconSuite-pipeline.py
cp GroupedAnalysisAmpSuite.py ${PREFIX}/bin/GroupedAnalysisAmpSuite.py

# Python command to install the package.
$PYTHON setup.py install --install-data aa_data_repo/ --single-version-externally-managed --record=record.txt
