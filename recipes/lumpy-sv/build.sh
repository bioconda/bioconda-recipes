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

make \
    CC="${CC}" \
    CXX="${CXX}" \
    CPPFLAGS="${CPPFLAGS}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ZLIB_PATH="${PREFIX/lib}"

echo '#!/bin/bash -e

# general
LUMPY_HOME=~/lumpy-sv

# HEXDUMP is used to determine if a file is a CRAM
HEXDUMP=`which hexdump || true`

LUMPY=`which lumpy || true`
SAMBLASTER=`which samblaster || true`
# either sambamba or samtools is required
SAMBAMBA=`which sambamba || true`
SAMTOOLS=`which samtools || true`

# python 2.7 or newer, must have pysam, numpy installed
PYTHON=`which python || true`

# python scripts
PAIREND_DISTRO=$LUMPY_HOME/scripts/pairend_distro.py
BAMGROUPREADS=$LUMPY_HOME/scripts/bamkit/bamgroupreads.py
BAMFILTERRG=$LUMPY_HOME/scripts/bamkit/bamfilterrg.py
BAMLIBS=$LUMPY_HOME/scripts/bamkit/bamlibs.py
' > $PREFIX/bin/lumpyexpress.config

cp bin/* $PREFIX/bin
cp scripts/lumpyexpress $PREFIX/bin
cp scripts/cnvanator_to_bedpes.py $PREFIX/bin

cp scripts/*.py $outdir/scripts
cp scripts/*.sh $outdir/scripts
cp scripts/*.pl $outdir/scripts
cp scripts/extractSplitReads* $outdir/scripts
cp scripts/vcf* $outdir/scripts

ln -s $outdir/scripts/extractSplitReads_BwaMem $PREFIX/bin

chmod +x $PREFIX/bin/extractSplitReads_BwaMem
