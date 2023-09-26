#!/bin/bash
#Based on https://github.com/TobyBaril/EarlGrey/blob/main/configure
set -x

# Define paths
PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
SCRIPT_DIR="${PACKAGE_HOME}/scripts/"


# Create directories
mkdir -p ${PREFIX}/bin
mkdir -p ${PACKAGE_HOME}


# Put package in share directory
cp -r * ${PACKAGE_HOME}/


# Install SA-SSR
git clone https://github.com/ridgelab/SA-SSR
cd SA-SSR
make
cp bin/sa-ssr ${PREFIX}/bin/


# Fixes to earlGrey executable
sed -i.bak "1s|^|#!/bin/bash\n|" ${PACKAGE_HOME}/earlGrey  #add bash shebang line
sed -i.bak "s|usage; exit 1|usage; exit 0|g" ${PACKAGE_HOME}/earlGrey  #let help return exit-code 0
sed -i.bak "/CONDA_DEFAULT_ENV/,+4d" ${PACKAGE_HOME}/earlGrey  #remove check that conda environment has a specific name


# Fixes sed command for executables so that it works on both linux and macos
sed -i.bak "s|sed -i |sed -i.bak |g" ${PACKAGE_HOME}/earlGrey ${SCRIPT_DIR}/rcMergeRepeat* ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh


# Add SCRIPT_DIR to correct path
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/earlGrey
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${SCRIPT_DIR}/rcMergeRepeat*
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${SCRIPT_DIR}/headSwap.sh
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${SCRIPT_DIR}/autoPie.sh
sed -i.bak "s|INSERT_FILENAME_HERE|${SCRIPT_DIR}/TEstrainer/scripts/|g" ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh


# Set permissions to files
chmod +x ${PACKAGE_HOME}/earlGrey
chmod +x ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
chmod +x ${SCRIPT_DIR}/* > /dev/null 2>&1
chmod +x ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
chmod a+w ${SCRIPT_DIR}/repeatCraft/example


# Extract tRNAdb
tar -zxf ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/tRNAdb.tar.gz --directory ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7


# Put earlGrey executable in bin
cd ${PREFIX}/bin
ln -s ${PACKAGE_HOME}/earlGrey .

