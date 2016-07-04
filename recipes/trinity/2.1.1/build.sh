#!/bin/bash

BINARY=Trinity
BINARY_HOME=$PREFIX/bin
TRINITY_HOME=$PREFIX/opt/trinity-$PKG_VERSION

cd $SRC_DIR

make inchworm_target
make chrysalis_target

cd $SRC_DIR/trinity-plugins/
make scaffold_iworm_contigs_target
cd $SRC_DIR

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


# Find real path when executing from a symlink
export LC_ALL=C
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'

# Replace hard coded path to deps
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/$FASTOOL_DIR\/fastool/fastool/g'
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/$JELLYFISH_DIR\/bin\/jellyfish/jellyfish/g'
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/$COLLECTL_DIR\///g'
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/${COLLECTL_DIR}\///g'
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/$PARAFLY -c/ParaFly -c/g'
sed -i.bak "s/\$ROOTDIR\/trinity-plugins\/Trimmomatic/\/opt\/anaconda1anaconda2anaconda3\/share\/trimmomatic/g" $TRINITY_HOME/Trinity

find $TRINITY_HOME -type f -name "*.bak" -print0 | xargs -0 rm -f
