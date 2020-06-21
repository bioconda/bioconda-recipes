#!/bin/bash

echo "debug1"
ls -l

# cd into the core directory, where the master pom.xml file (Maven build file) is located.
cd core

echo "debug2"
ls -l

# Run mvn clean install to build and install (into your local Maven repository) all of the modules for InterProScan 5.
mvn clean install

echo "debug3"
ls -l

# cd into the jms-implementation directory and run mvn clean package
 cd jms-implementation

echo "debug4"
ls -l

mvn clean package

echo "debug5"
ls -l

# mv interproscan.sh in the bin
mkdir -p ${PREFIX}/bin
cp interproscan-5-dist/interproscan.sh  ${PREFIX}/bin/

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
