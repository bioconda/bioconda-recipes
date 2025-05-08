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
cp -rf * ${PACKAGE_HOME}/

# Install SA-SSR (has to be done here because SA-SSR is an ancient repository without releases)
git clone --depth 1 https://github.com/TobyBaril/SA-SSR
cd SA-SSR
make
cp -f bin/sa-ssr ${PREFIX}/bin/
cd ../ && rm -rf SA-SSR/

# Fixes to earlGrey executable
sed -i.bak "/CONDA_DEFAULT_ENV/,+4d" ${PACKAGE_HOME}/earlGrey  #remove check that conda environment has a specific name
sed -i.bak "/CONDA_DEFAULT_ENV/,+4d" ${PACKAGE_HOME}/earlGreyLibConstruct  #remove check that conda environment has a specific name
sed -i.bak "/CONDA_DEFAULT_ENV/,+4d" ${PACKAGE_HOME}/earlGreyAnnotationOnly  #remove check that conda environment has a specific name

# Fixes sed command for executables so that it works on both linux and macos
sed -i.bak "s|sed -i |sed -i.bak |g" ${PACKAGE_HOME}/earlGrey ${PACKAGE_HOME}/earlGreyLibConstruct ${PACKAGE_HOME}/earlGreyAnnotationOnly ${SCRIPT_DIR}/rcMergeRepeat* ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh

# Remove -pa from RepeatClassifier
sed -i.bak 's/RepeatClassifier -pa ${THREADS} /RepeatClassifier /' ${SCRIPT_DIR}/TEstrainer/TEstrainer

# Remove -t parameter from sa-ssr (since multithreading doesn't work on OSX)
sed -i.bak 's/-t ${THREADS} / /' ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
sed -i.bak 's/-t ${THREADS} / /' ${SCRIPT_DIR}/TEstrainer/TEstrainer

# Add SCRIPT_DIR to correct path
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/earlGrey
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/earlGreyLibConstruct
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${PACKAGE_HOME}/earlGreyAnnotationOnly
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${SCRIPT_DIR}/rcMergeRepeat*
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${SCRIPT_DIR}/headSwap.sh
sed -i.bak "s|SCRIPT_DIR=.*|SCRIPT_DIR=${SCRIPT_DIR}|g" ${SCRIPT_DIR}/autoPie.sh
sed -i.bak "s|STRAIN_SCRIPTS=.*|STRAIN_SCRIPTS=${SCRIPT_DIR}/TEstrainer/scripts/|g" ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh

# Set permissions to files
chmod +x ${PACKAGE_HOME}/earlGrey
chmod +x ${PACKAGE_HOME}/earlGreyLibConstruct
chmod +x ${PACKAGE_HOME}/earlGreyAnnotationOnly
chmod +x ${SCRIPT_DIR}/TEstrainer/TEstrainer_for_earlGrey.sh
chmod +x ${SCRIPT_DIR}/* > /dev/null 2>&1
chmod +x ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/ltr_finder
chmod a+w ${SCRIPT_DIR}/repeatCraft/example

# Extract tRNAdb
tar -zxf ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/tRNAdb.tar.gz --directory ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7 && rm -r ${SCRIPT_DIR}/bin/LTR_FINDER.x86_64-1.0.7/tRNAdb.tar.gz

# test for conda
df -h

# Set PERL5LIB upon activate/deactivate
for CHANGE in "activate" "deactivate";
do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
done
echo "#!/bin/sh" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "export PERL5LIB=${PREFIX}/share/RepeatMasker/:${PREFIX}/share/RepeatModeler/" >> "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "#!/bin/sh" > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
echo "unset PERL5LIB" >> "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"

# Put earlGrey executable in bin
cd ${PREFIX}/bin
ln -sf ${PACKAGE_HOME}/earlGrey .
ln -sf ${PACKAGE_HOME}/earlGreyLibConstruct .
ln -sf ${PACKAGE_HOME}/earlGreyAnnotationOnly .
