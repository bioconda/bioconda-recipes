#!/bin/sh
set -x -e

echo "CFLAGS=$CFLAGS"
echo "CPPFLAGS=$CPPFLAGS"
echo "CXXFLAGS=$CXXFLAGS"
echo "LDFLAGS=$LDFLAGS"

pushd deps/boost

# Copied from https://github.com/conda-forge/boost-feedstock/blob/master/recipe/build.sh


INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

# Always build PIC code for enable static linking into other shared libraries
CXXFLAGS="${CXXFLAGS} -fPIC"

if [ "$(uname)" == "Darwin" ]; then
    TOOLSET=clang
elif [ "$(uname)" == "Linux" ]; then
    TOOLSET=gcc
fi

# http://www.boost.org/build/doc/html/bbv2/tasks/crosscompile.html
cat <<EOF > ${SRC_DIR}/deps/boost/tools/build/src/site-config.jam
using ${TOOLSET} : custom : ${CXX} ;
EOF

LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"


./bootstrap.sh --prefix=build --with-toolset=cc --with-libraries=chrono,exception,program_options,timer,filesystem,system,stacktrace

# https://svn.boost.org/trac10/ticket/5917
# https://stackoverflow.com/a/5244844/1005215
sed -i.bak "s,cc,${TOOLSET},g" ${SRC_DIR}/deps/boost/project-config.jam

./b2 -d+2 \
    variant=release \
    address-model="${ARCH}" \
    architecture=x86 \
    debug-symbols=off \
    threading=multi \
    runtime-link=shared \
    link=static \
    toolset=${TOOLSET}-custom \
    include="${INCLUDE_PATH}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LINKFLAGS}" \
    --layout=system \
    -j"${CPU_COUNT}" install
# install 2>&1 | tee b2.log

popd


export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./autogen.sh
./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
make V=1
# make V=1 check
make install
