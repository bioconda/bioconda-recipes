#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

#export CXXFLAGS=" -std=c++11 -stdlib=libstdc++ -stdlib=libc++ -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export CXXFLAGS=" -std=c++11  -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR} -I${BUILD_PREFIX}/include/bamtools"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"
export BAMTOOLS="${BUILD_PREFIX}"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/config
#mkdir bin

# This has been corrected on github, but not in a release
sed -i.bak "s#PREFIX#BUILD_PREFIX#g" auxprogs/bam2hints/Makefile
sed -i.bak "s#PREFIX#BUILD_PREFIX#g" auxprogs/filterBam/src/Makefile
cat auxprogs/filterBam/src/Makefile
#pushd auxprogs/
#pushd bam2hints/
#make CXX="${CXX}" BAMTOOLS="${BUILD_PREFIX}" CFLAGS="${CXXFLAGS} -std=c++11 -DNDEBUG -D_FORTIFY_SOURCE=2"
#popd
#pushd filterBam/src/
#make CXX="${CXX}" BAMTOOLS="${BUILD_PREFIX}" CFLAGS="${CXXFLAGS} -std=c++11 -DNDEBUG -D_FORTIFY_SOURCE=2"
#popd
#popd

## Make the software

if [ "$(uname)" == Darwin ] ; then
  # SQLITE disabled due to compile issue, see: https://svn.boost.org/trac10/ticket/13501
  make CC="${CC}" CXX="${CXX}" COMPGENPRED=true BAMTOOLS=${BUILD_PREFIX} BAMTOOLS_CC=${CC} BAMTOOLS_CXX=${CXX}
else
  make CC="${CC}" CXX="${CXX}" COMPGENPRED=true SQLITE=true BAMTOOLS=${BUILD_PREFIX} BAMTOOLS_CC=${CC} BAMTOOLS_CXX=${CXX}
fi


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
