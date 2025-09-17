#!/bin/bash
#Based on https://github.com/TobyBaril/EarlGrey/blob/main/configure
set -x

# Define paths
PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}

# create directories
mkdir -p ${PREFIX}/bin
mkdir -p ${PACKAGE_HOME}

# put package in share directory
cp -rf * ${PACKAGE_HOME}/

# fix file paths
BCHECK=${PACKAGE_HOME}/heliano_bcheck.R
FISHER=${PACKAGE_HOME}/heliano_fisher.R
HMMmodel=${PACKAGE_HOME}/RepHel.hmm
Headermodel=${PACKAGE_HOME}/tclcv.txt
SPLIT=${PACKAGE_HOME}/SplitJoint.R
SORT=${PACKAGE_HOME}/Sort.sh

sed -i.bak "s|_INTERPRETERPYTHON_PATH_|/usr/bin/env python|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_HMM_|${HMMmodel}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_HEADER_|${Headermodel}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_FISHER_|${FISHER}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_BOUNDARY_|${BCHECK}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_SPLIT_JOINT_|${SPLIT}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_SORTPRO_|${SORT}|" ${PACKAGE_HOME}/heliano.py

# set permissions to files
chmod +x ${PACKAGE_HOME}/heliano.py
chmod +x ${PACKAGE_HOME}/heliano_cons.py

# put files in the executable bin
cd ${PREFIX}/bin || exit 1
ln -sf "${PACKAGE_HOME}/heliano.py" heliano
ln -sf "${PACKAGE_HOME}/heliano_cons.py" heliano_cons
