#!/bin/bash

set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I${PREFIX}/include"


BINARY_HOME=$PREFIX/bin
TRINITY_HOME=$PREFIX/opt/trinity-$PKG_VERSION

cd $SRC_DIR

make
make plugins

# remove the sample data
rm -rf $SRC_DIR/sample_data

# copy source to bin
mkdir -p $PREFIX/bin
mkdir -p $TRINITY_HOME
cp -R $SRC_DIR/* $TRINITY_HOME/
cd $TRINITY_HOME && chmod +x Trinity

# add link to Trinity from bin so in PATH
cd $BINARY_HOME
ln -s $TRINITY_HOME/Trinity
ln -s $TRINITY_HOME/util/*.pl .
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/PtR
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/run_DE_analysis.pl
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/analyze_diff_expr.pl
ln -s $TRINITY_HOME/Analysis/DifferentialExpression/define_clusters_by_cutting_tree.pl
ln -s $TRINITY_HOME/Analysis/SuperTranscripts/Trinity_gene_splice_modeler.py
ln -s $TRINITY_HOME/Analysis/SuperTranscripts/extract_supertranscript_from_reference.py
ln -s $TRINITY_HOME/util/support_scripts/get_Trinity_gene_to_trans_map.pl
ln -s $TRINITY_HOME/util/misc/contig_ExN50_statistic.pl
cp $TRINITY_HOME/trinity-plugins/BIN/seqtk-trinity .

# Find real path when executing from a symlink
export LC_ALL=C
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'

# Replace hard coded path to deps
find $TRINITY_HOME -type f -print0 | xargs -0 sed -i.bak 's/$JELLYFISH_DIR\/bin\/jellyfish/jellyfish/g'
sed -i.bak "s/\$ROOTDIR\/trinity-plugins\/Trimmomatic/\/opt\/anaconda1anaconda2anaconda3\/share\/trimmomatic/g" $TRINITY_HOME/Trinity

find $TRINITY_HOME -type f -name "*.bak" -print0 | xargs -0 rm -f

# make it easier to find TRINITY_HOME
ln -sf $TRINITY_HOME $PREFIX/opt/TRINITY_HOME
