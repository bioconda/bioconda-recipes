#!/bin/bash

#Building according to instructions at Schmutzi repository

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
BINARY_HOME=$PREFIX/BIN
SCHMUTZI_HOME=$PREFIX/opt/schmutzi-$PKG_VERSION

make

#Now copy over data to bin
mkdir -p $PREFIX/bin
mkdir -p $SCHMUTZI_HOME

cp -R $SRC_DIR/* $SCHMUTZI_HOME
cd $SCHMUTZI_HOME && chmod +x contDeam endoCaller log2fasta mtCont approxDist.R schmutzi.pl mtCont bam2prof insertSize log2freq logs2pos mitoConsPDF.R mas2freq mas2log posteriorDeam.R contOut2ContEst.pl

#Link binaries appropriately
cd $BINARY_HOME
ln -s $SCHMUTZI_HOME/contDeam contDeam
ln -s $SCHMUTZI_HOME/endCaller endoCaller
ln -s $SCHMUTZI_HOME/mtCont mtCont
ln -s $SCHMUTZI_HOME/approxDist.R approxDist.R 
ln -s $SCHMUTZI_HOME/schmutzi.pl schmutzi.pl
ln -s $SCHMUTZI_HOME/bam2prof bam2prof
ln -s $SCHMUTZI_HOME/insertSize insertSize
ln -s $SCHMUTZI_HOME/log2freq log2freq
ln -s $SCHMUTZI_HOME/logs2pos logs2pos
ln -s $SCHMUTZI_HOME/log2fasta log2fasta
ln -s $SCHMUTZI_HOME/mitoConsPDF.R mitoConsPDF.R 
ln -s $SCHMUTZI_HOME/mas2freq mas2freq
ln -s $SCHMUTZI_HOME/mas2log mas2log
ln -s $SCHMUTZI_HOME/posteriorDeam.R posteriorDeam.R 
ln -s $SCHMUTZI_HOME/contOut2ContEst.pl contOut2ContEst.pl