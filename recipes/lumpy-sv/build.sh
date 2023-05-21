#!/bin/bash
set -eu -o pipefail

# The project's Makefiles don't use {CPP,C,CXX,LD}FLAGS everywhere.
# We can try to patch all of those or export the following *_PATH variables.
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export ZLIB_PATH="${PREFIX}/lib/"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/scripts
mkdir -p $PREFIX/bin

cp scripts/lumpyexpress $PREFIX/bin
cp scripts/cnvanator_to_bedpes.py $PREFIX/bin

cp scripts/*.py $outdir/scripts
cp scripts/*.sh $outdir/scripts
cp scripts/*.pl $outdir/scripts
cp scripts/extractSplitReads* $outdir/scripts
cp scripts/vcf* $outdir/scripts
ln -s $outdir/scripts/extractSplitReads_BwaMem $PREFIX/bin
ln -s $outdir/scripts/pairend_distro.py $PREFIX/bin

chmod +x $PREFIX/bin/extractSplitReads_BwaMem

# The file lumpyexpress.config links the scripts to the install path, we need to change to the run path so basically we rebuild it
export BIN_DIR=$PREFIX/bin
touch ${BIN_DIR}/lumpyexpress.config
echo "LUMPY_HOME=$outdir" >> ${BIN_DIR}/lumpyexpress.config
echo "" >> ${BIN_DIR}/lumpyexpress.config
echo "LUMPY=${BIN_DIR}/lumpy" >> ${BIN_DIR}/lumpyexpress.config
echo "HEXDUMP=hexdump" >> ${BIN_DIR}/lumpyexpress.config
echo "SAMBLASTER=samblaster" >> ${BIN_DIR}/lumpyexpress.config
echo "SAMBAMBA=sambamba" >> ${BIN_DIR}/lumpyexpress.config
echo "SAMTOOLS=samtools" >> ${BIN_DIR}/lumpyexpress.config
echo "PYTHON=python" >> ${BIN_DIR}/lumpyexpress.config
echo "" >> ${BIN_DIR}/lumpyexpress.config
echo "PAIREND_DISTRO=$outdir/scripts/pairend_distro.py" >> ${BIN_DIR}/lumpyexpress.config
echo "BAMGROUPREADS=${BIN_DIR}/bamgroupreads.py" >> ${BIN_DIR}/lumpyexpress.config
echo "BAMFILTERRG=${BIN_DIR}/bamfilterrg.py" >> ${BIN_DIR}/lumpyexpress.config
echo "BAMLIBS=${BIN_DIR}/bamlibs.py" >> ${BIN_DIR}/lumpyexpress.config

