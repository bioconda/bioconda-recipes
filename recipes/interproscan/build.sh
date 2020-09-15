#!/bin/bash

# cd into the core directory, where the master pom.xml file (Maven build file) is located.
cd core

# Run mvn clean install to build and install (into your local Maven repository) all of the modules for InterProScan 5.
mvn clean install

# cd into the jms-implementation directory and run mvn clean package
cd jms-implementation

mvn clean package

echo "debug5"
ls -l
ls -l target/
ls -l target/interproscan-5-dist/

# copy result into the share folder
IPR_DIR=${PREFIX}/share/InterProScan
cp -r target/interproscan-5-dist/* $IPR_DIR/

# mv interproscan.sh in the bin
mkdir -p ${PREFIX}/bin
ln -s $IPR_DIR//interproscan.sh  ${PREFIX}/bin/

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
