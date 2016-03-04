#!/bin/bash

BINARY=Trinity
BINARY_HOME=$PREFIX/bin
TRINITY_HOME=$PREFIX/opt/trinity-$PKG_VERSION

cd $SRC_DIR

#make

# remove the sample data
rm -rf $SRC_DIR/sample_data

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $TRINITY_HOME
cp -R $SRC_DIR/* $TRINITY_HOME/
cd $TRINITY_HOME && chmod +x Trinity
cd $BINARY_HOME && ln -s $TRINITY_HOME/Trinity $BINARY
ln -s $TRINITY_HOME/util/* .
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/PtR
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/run_DE_analysis.pl

ln -s $TRINITY_HOME/trinity-plugins/collectl/bin/client.pl
ln -s $TRINITY_HOME/trinity-plugins/collectl/bin/col2tlviz.pl
ln -s $TRINITY_HOME/trinity-plugins/collectl/bin/collectl
ln -s $TRINITY_HOME/trinity-plugins/collectl/bin/collectl2html
ln -s $TRINITY_HOME/trinity-plugins/fastool/fastool
ln -s $TRINITY_HOME/trinity-plugins/jellyfish/bin/jellyfish
ln -s $TRINITY_HOME/trinity-plugins/parafly/bin/ParaFly
ln -s $TRINITY_HOME/trinity-plugins/Trimmomatic/trimmomatic.jar
ln -s $TRINITY_HOME/trinity-plugins/slclust/bin/slclust
ln -s $TRINITY_HOME/trinity-plugins/GAL_0.2.1/fasta_tool
ln -s $TRINITY_HOME/trinity-plugins/BIN/samtools
ln -s $TRINITY_HOME/trinity-plugins/htslib/bgzip
ln -s $TRINITY_HOME/trinity-plugins/htslib/htsfile
ln -s $TRINITY_HOME/trinity-plugins/htslib/tabix


export LC_ALL=C
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'
