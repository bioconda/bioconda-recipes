#!/bin/bash

set -x -e

#export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libstdc++ -stdlib=libc++ -DUSE_BOOST"
export CXXFLAGS="${CXXFLAGS} -std=c++11  -DUSE_BOOST -I${PREFIX}/include/bamtools"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config

## Make the software

if [ "$(uname)" = Darwin ] ; then
    # SQLITE disabled due to compile issue, see: https://svn.boost.org/trac10/ticket/13501
    sqlite=
else
    sqlite='SQLITE=true'
fi
make \
    CC="${CC}" \
    CXX="${CXX}" \
    BAMTOOLS_CC="${CC}" \
    BAMTOOLS_CXX="${CXX}" \
    BAMTOOLS="${PREFIX}" \
    COMPGENPRED=true \
    $sqlite


## Build Perl

mkdir perl-build
find scripts -name "*.pl" | xargs -I {} mv {} perl-build
cd perl-build
# affects tests for Augustus 3.3:
# https://github.com/Gaius-Augustus/Augustus/commit/7ca3ab
sed -i'' -e '1s/perl -w/perl/' *.pl
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..


## End build perl

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
