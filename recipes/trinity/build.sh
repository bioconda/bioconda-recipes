#!/bin/bash -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-parameter -Wno-sign-compare -Wno-deprecated-declarations"

export BINARY_HOME="${PREFIX}/bin"
export TRINITY_HOME="${PREFIX}/opt/trinity-${PKG_VERSION}"

if [[ "$(uname)" == "Darwin" ]]; then
	# for Mac OSX
	export CXXFLAGS="${CXXFLAGS} -std=c++14"
fi

sed -i.bak 's|VERSION 3.1|VERSION 3.5|' Chrysalis/CMakeLists.txt
sed -i.bak 's|-O2|-O3|' Chrysalis/CMakeLists.txt
sed -i.bak 's|VERSION 3.1|VERSION 3.5|' Inchworm/CMakeLists.txt
sed -i.bak 's|-O2|-O3|' Inchworm/CMakeLists.txt
rm -rf Chrysalis/*.bak
rm -rf Inchworm/*.bak

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}" plugins
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

make install

# remove the sample data
rm -rf ${SRC_DIR}/sample_data

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${TRINITY_HOME}/util/*.pl
rm -rf ${TRINITY_HOME}/util/*.bak
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${TRINITY_HOME}/util/misc/*.pl
rm -rf ${TRINITY_HOME}/util/misc/*.bak
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${TRINITY_HOME}/util/support_scripts/*.pl
rm -rf ${TRINITY_HOME}/util/support_scripts/*.bak

# add link to Trinity from bin so in PATH
cd ${BINARY_HOME}
ln -sf ${TRINITY_HOME}/Trinity
ln -sf ${TRINITY_HOME}/util/*.pl .
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/PtR
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/run_DE_analysis.pl
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/analyze_diff_expr.pl
ln -sf ${TRINITY_HOME}/Analysis/DifferentialExpression/define_clusters_by_cutting_tree.pl
ln -sf ${TRINITY_HOME}/Analysis/SuperTranscripts/Trinity_gene_splice_modeler.py
ln -sf ${TRINITY_HOME}/Analysis/SuperTranscripts/extract_supertranscript_from_reference.py
ln -sf ${TRINITY_HOME}/util/support_scripts/get_Trinity_gene_to_trans_map.pl
ln -sf ${TRINITY_HOME}/util/misc/contig_ExN50_statistic.pl
cp -rf ${TRINITY_HOME}/trinity-plugins/BIN/seqtk-trinity .

# Find real path when executing from a symlink
export LC_ALL="en_US.UTF-8"
find ${TRINITY_HOME} -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'

# Replace hard coded path to deps
find ${TRINITY_HOME} -type f -print0 | xargs -0 sed -i.bak 's/$JELLYFISH_DIR\/bin\/jellyfish/jellyfish/g'
sed -i.bak "s/\$ROOTDIR\/trinity-plugins\/Trimmomatic/\/opt\/anaconda1anaconda2anaconda3\/share\/trimmomatic/g" ${TRINITY_HOME}/Trinity
sed -i.bak 's/my $TRIMMOMATIC = "\([^"]\+\)"/my $TRIMMOMATIC = '"'"'\1'"'"'/' ${TRINITY_HOME}/Trinity
sed -i.bak 's/my $TRIMMOMATIC_DIR = "\([^"]\+\)"/my $TRIMMOMATIC_DIR = '"'"'\1'"'"'/' ${TRINITY_HOME}/Trinity

find ${TRINITY_HOME} -type f -name "*.bak" -print0 | xargs -0 rm -f

# export TRINITY_HOME as ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export TRINITY_HOME=${TRINITY_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset TRINITY_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
