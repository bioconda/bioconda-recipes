#!/bin/bash


# run only for the log to see if path is ok
./configure.sh -j=${JAVA_HOME}
#  . ./ syntax does not work. Lets import direclty what is needed
        export DEV_ROOT=`pwd`
        export BEDTOOLS_PATH=bedtools
        export SAMTOOLS_PATH=samtools
        export RESOURCES_DIR="${DEV_ROOT}/Resources"
        export JAVA_HOME=${JAVA_HOME}
        export BAM_UTILS_PATH=bam
        export PYTHON27_PATH=python
        export DONT_DOWNLOAD=true
        export DONT_WRITE=false
        export IS_UNIX=true

make

# put the exe in the bin
mkdir -p ${PREFIX}/bin
cp RNAEditingIndex ${PREFIX}/bin
