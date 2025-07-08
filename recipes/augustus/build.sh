#!/bin/bash
set -x -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -DUSE_BOOST"
export LC_ALL="en_US.UTF-8"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config

sed -i.bak 's|3.4.0|3.5.0|' common.mk
rm -rf *.bak

## Make the software
if [[ "$(uname -s)" = "Darwin" ]]; then
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
	INCLUDE_PATH_BOOST="-I${PREFIX}/include/boost" \
	LIBRARY_PATH_BOOST="-L${PREFIX}/lib" \
	COMPGENPRED=true \
	MYSQL=false \
	"${sqlite}" \
	-j"${CPU_COUNT}"

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/scripts/*.pl
rm -rf ${SRC_DIR}/scripts/*.bak

## Build Perl
mkdir perl-build
find scripts -name "*.pl" | xargs -I {} mv {} perl-build
cd perl-build

cp -f ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..

## End build perl

install -v -m 0755 bin/* "${PREFIX}/bin"
install -v -m 0755 scripts/* "${PREFIX}/bin"
mv config/* ${PREFIX}/config/

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
