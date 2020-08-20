#!/bin/sh

mkdir build
cd build
# To run boost linking $CC and $CXX to gcc and g++
ln -s $CC ${PREFIX}/bin/gcc
ln -s $CXX ${PREFIX}/bin/g++
cmake \
    -D CMAKE_BUILD_TYPE=release \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

make
make install

# Make bam2cfg.pl work from bin; it needs some modules from lib.
BAM2CFG_LIB=`dirname $( find ${PREFIX}/lib -name "bam2cfg.pl" )`
${PREFIX}/bin/sed -i'' "s@use AlnParser;@use lib \"${BAM2CFG_LIB}\";\nuse AlnParser;@" ${BAM2CFG_LIB}/bam2cfg.pl
ln -s ${BAM2CFG_LIB}/bam2cfg.pl ${PREFIX}/bin
# copy samtools to bin
cp vendor/samtools/samtools ${PREFIX}/bin
# Remove the fake links
unlink ${PREFIX}/bin/gcc
unlink ${PREFIX}/bin/g++
