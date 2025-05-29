#!/bin/bash -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-parameter -Wno-sign-compare -Wno-deprecated-declarations"

export BINARY_HOME="${PREFIX}/bin"
export LC_ALL="en_US.UTF-8"

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

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/util/*.pl
rm -rf ${SRC_DIR}/util/*.bak
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/util/misc/*.pl
rm -rf ${SRC_DIR}/util/misc/*.bak
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/util/support_scripts/*.pl
rm -rf ${SRC_DIR}/util/support_scripts/*.bak

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}" plugins
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

make install

# remove the sample data
rm -rf ${SRC_DIR}/sample_data

# Find real path when executing from a symlink
find ${BINARY_HOME} -type f -print0 | xargs -0 sed -i.bak 's/FindBin::Bin/FindBin::RealBin/g'

# Replace hard coded path to deps
find ${BINARY_HOME} -type f -print0 | xargs -0 sed -i.bak 's/$JELLYFISH_DIR\/bin\/jellyfish/jellyfish/g'
sed -i.bak "s/\$ROOTDIR\/trinity-plugins\/Trimmomatic/\/opt\/anaconda1anaconda2anaconda3\/share\/trimmomatic/g" ${BINARY_HOME}/Trinity
sed -i.bak 's/my $TRIMMOMATIC = "\([^"]\+\)"/my $TRIMMOMATIC = '"'"'\1'"'"'/' ${BINARY_HOME}/Trinity
sed -i.bak 's/my $TRIMMOMATIC_DIR = "\([^"]\+\)"/my $TRIMMOMATIC_DIR = '"'"'\1'"'"'/' ${BINARY_HOME}/Trinity

find ${BINARY_HOME} -type f -name "*.bak" -print0 | xargs -0 rm -f

# export TRINITY_HOME as ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export TRINITY_HOME=${BINARY_HOME}" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset TRINITY_HOME" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
