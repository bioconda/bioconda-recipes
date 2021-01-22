#!/bin/bash
TOOL_BASE=${PREFIX}/share
TOOL_DIR=${TOOL_BASE}/RNAEditingIndexer
mkdir -p ${TOOL_BASE}
cd ${TOOL_BASE}
git clone https://github.com/shalomhillelroth/RNAEditingIndexer
cd RNAEditingIndexer

# run only for the log to see if path is ok
./configure.sh -j=${JAVA_HOME}
#  . ./ syntax does not work. Lets import direclty what is needed
        export DEV_ROOT=${TOOL_DIR}
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
ls -l
chmod 755 RNAEditingIndex
ln -s RNAEditingIndex ${PREFIX}/bin/RNAEditingIndex
ls -l ${PREFIX}/bin
