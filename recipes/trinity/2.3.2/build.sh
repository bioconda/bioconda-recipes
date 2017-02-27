#!/bin/bash

set -x -e

# fix automake
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/automake

# fix autoconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autom4te
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/ifnames
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoscan
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoupdate

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"


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
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/analyze_diff_expr.pl
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/define_clusters_by_cutting_tree.pl
ln -s $TRINITY_HOME/util/support_scripts/get_Trinity_gene_to_trans_map.pl
ln -s $TRINITY_HOME/util/misc/contig_ExN50_statistic.pl

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
