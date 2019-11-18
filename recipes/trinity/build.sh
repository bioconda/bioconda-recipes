#!/bin/bash
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"
export CPPFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"
export CFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"

BINARY_HOME=$PREFIX/bin
TRINITY_HOME=$PREFIX/opt/trinity-$PKG_VERSION

make plugins CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"

# remove the sample data
#rm -rf $SRC_DIR/sample_data

# reproduce make install without the wrapper script
mkdir -p $PREFIX/bin
mkdir -p $TRINITY_HOME/Butterfly
chmod +x Trinity
cp Trinity $TRINITY_HOME/
mv Analysis $TRINITY_HOME/
cp Butterfly/Butterfly.jar $TRINITY_HOME/Butterfly
mkdir -p $TRINITY_HOME/Chrysalis
cp -LR Chrysalis/bin $TRINITY_HOME/Chrysalis
mkdir -p $TRINITY_HOME/Inchworm
cp -LR Inchworm/bin $TRINITY_HOME/Inchworm
cp -LR PerlLib $TRINITY_HOME/
cp -LR PyLib $TRINITY_HOME/
cp -LR trinity-plugins $TRINITY_HOME/
cp -LR util $TRINITY_HOME/

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
sed -i 's/my $TRIMMOMATIC = "\([^"]\+\)"/my $TRIMMOMATIC = '"'"'\1'"'"'/' $TRINITY_HOME/Trinity
sed -i 's/my $TRIMMOMATIC_DIR = "\([^"]\+\)"/my $TRIMMOMATIC_DIR = '"'"'\1'"'"'/' $TRINITY_HOME/Trinity


find $TRINITY_HOME -type f -name "*.bak" -print0 | xargs -0 rm -f

# export TRINITY_HOME as ENV variable 
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export TRINITY_HOME=${TRINITY_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset TRINITY_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh

