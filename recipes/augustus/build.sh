#!/bin/bash

set -x -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -DUSE_BOOST -I${PREFIX}/include"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config

## Make the software
if [[ "$(uname)" = Darwin ]]; then
	# SQLITE disabled due to compile issue, see: https://svn.boost.org/trac10/ticket/13501
	sqlite=
else
	sqlite='SQLITE=true'
fi

make \
	CC="${CC}" \
	CXX="${CXX}" \
	INCLUDE_PATH_BAMTOOLS="-I${PREFIX}/include/bamtools" \
	LIBRARY_PATH_BAMTOOLS="-L${PREFIX}/lib" \
	INCLUDE_PATH_LPSOLVE="-I${PREFIX}/include/lpsolve" \
	LIBRARY_PATH_LPSOLVE="-L${PREFIX}/lib" \
	INCLUDE_PATH_HTSLIB="-I${PREFIX}/include/htslib" \
	LIBRARY_PATH_HTSLIB="-L${PREFIX}/lib" \
	COMPGENPRED=true \
	MYSQL=false \
	"${sqlite}" -j"${CPU_COUNT}"

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/scripts/*.pl
rm -rf ${SRC_DIR}/scripts/*.bak

## Build Perl

mkdir perl-build
find scripts -name "*.pl" | xargs -I {} mv {} perl-build
cd perl-build
# affects tests for Augustus 3.3:
# https://github.com/Gaius-Augustus/Augustus/commit/7ca3ab
#sed -i'' -e '1s/perl -w/perl/' *.pl
cp -f ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..


## End build perl

chmod 0755 bin/augustus
mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/bin/
mv config/* $PREFIX/config/

## Set AUGUSTUS variables on env activation

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/augustus.sh
export AUGUSTUS_CONFIG_PATH=${PREFIX}/config/
export AUGUSTUS_SCRIPTS_PATH=${PREFIX}/bin/
export AUGUSTUS_BIN_PATH=${PREFIX}/bin/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/augustus.sh
unset AUGUSTUS_CONFIG_PATH
unset AUGUSTUS_SCRIPTS_PATH
unset AUGUSTUS_BIN_PATH
EOF
