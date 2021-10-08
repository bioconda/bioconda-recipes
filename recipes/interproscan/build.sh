#!/bin/bash

# create IPR dir
IPR_DIR=${PREFIX}/share/InterProScan
mkdir -p ${IPR_DIR}

# get the md5 of the databases
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/{{ version_major }}-{{ version_minor }}/interproscan-{{ version_major }}-{{ version_minor }}-64-bit.tar.gz.md5
# get the databases (with core because much faster to download)
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/{{ version_major }}-{{ version_minor }}/interproscan-{{ version_major }}-{{ version_minor }}-64-bit.tar.gz   
# checksum
md5sum -c interproscan-{{ version_major }}-{{ version_minor }}-64-bit.tar.gz.md5
# untar gz
tar xvzf interproscan-{{ version_major }}-{{ version_minor }}-64-bit.tar.gz.md5
# keep path to the db
db_path=`pwd`

# cd into the core directory, where the master pom.xml file (Maven build file) is located.
cd core

# coils must be recompiled - version from bioconda is different than the one shipped within Interproscan
current_dir=`pwd`
cd jms-implementation/support-mini-x86-32/src/coils/ncoils/2.2.1/
# remove CC=gcc from Makefile
perl -ni -e 'print unless $. == 1' Makefile
make
cp ncoils ../../../../bin/ncoils/2.2.1/
cd ${current_dir}

# Run mvn clean install to build and install (into your local Maven repository) all of the modules for InterProScan 5.
mvn clean install

# cd into the jms-implementation directory and run mvn clean package
cd jms-implementation
mvn clean package

# copy result into the share folder
cp -r target/interproscan-5-dist/* ${IPR_DIR}/

# mv interproscan.sh in the bin
mkdir -p ${PREFIX}/bin
ln -s $IPR_DIR/interproscan.sh  ${PREFIX}/bin/

# copy properties file to replace the default one
cp ${RECIPE_DIR}/interproscan.properties ${IPR_DIR}/interproscan.properties

#remove old db
rm -rf ${IPR_DIR}/data
# copy new databases
cp ${db_path}/interproscan-{{ version_major }}-{{ version_minor }}/data ${IPR_DIR}/

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
