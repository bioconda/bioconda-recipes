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
myPYTHON_PATH=`which python3`

sed -i.bak "s|_INTERPRETERPYTHON_PATH_|${myPYTHON_PATH}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_HMM_|${HMMmodel}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_HEADER_|${Headermodel}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_FISHER_|${FISHER}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_BOUNDARY_|${BCHECK}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_SPLIT_JOINT_|${SPLIT}|" ${PACKAGE_HOME}/heliano.py
sed -i.bak "s|_SORTPRO_|${SORT}|" ${PACKAGE_HOME}/heliano.py

# set permissions to files
cp ${PACKAGE_HOME}/heliano.py ${PACKAGE_HOME}/heliano
cp ${PACKAGE_HOME}/heliano_cons.py ${PACKAGE_HOME}/heliano_cons
chmod +x ${PACKAGE_HOME}/heliano
chmod +x ${PACKAGE_HOME}/heliano_cons

# test for conda
df -h

# put files in the executable bin
cd ${PREFIX}/bin
ln -sf ${PACKAGE_HOME}/heliano
ln -sf ${PACKAGE_HOME}/heliano_cons
mv heliano heliano_cons bin/

echo "Succeed! Please find programs in bin/ directory."
