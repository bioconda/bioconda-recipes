#!/bin/bash
#Based on https://github.com/TobyBaril/EarlGrey/blob/main/configureForDocker

# Put package in share directory
PACKAGE_HOME=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${PACKAGE_HOME}
cp -r * ${PACKAGE_HOME}/


# Fixes to earlGrey executable
sed -i.bak "1s|^|#!/bin/bash\n|" ${PACKAGE_HOME}/earlGrey  #add bash shebang line
sed -i.bak "s|usage; exit 1|usage; exit 0|g" ${PACKAGE_HOME}/earlGrey  #let help return exit-code 0
sed -i.bak "/CONDA_DEFAULT_ENV/,+4d" ${PACKAGE_HOME}/earlGrey  #remove check that conda environment has a specific name


# Add SCRIPT_DIR to correct path
SCRIPT_DIR="${PACKAGE_HOME}/scripts/"
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/earlGrey
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/scripts/rcMergeRepeat*
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/scripts/headSwap.sh
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/scripts/autoPie.sh
sed -i.bak "s|INSERT_FILENAME_HERE|${SCRIPT_DIR}/TEstrainer/scripts/|g" ${PACKAGE_HOME}/scripts/TEstrainer/TEstrainer_for_earlGrey.sh


# Set permissions to files
chmod +x ${PACKAGE_HOME}/earlGrey
chmod +x ${PACKAGE_HOME}/modules/trf409.linux64
chmod +x ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
chmod +x ${SCRIPT_DIR}/* > /dev/null 2>&1
chmod +x ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
chmod a+w ${SCRIPT_DIR}/repeatCraft/example


# Extract tRNAdb
tar -zxf ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/tRNAdb.tar.gz --directory ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7


# Put earlGrey executable in bin
mkdir -p ${PREFIX}/bin
cd ${PREFIX}/bin
ln -s ${PACKAGE_HOME}/earlGrey .

