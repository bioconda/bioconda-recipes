#!/bin/bash
set -ex

mkdir -p "$PREFIX/bin"

# taken from yacrd recipe, see: https://github.com/bioconda/bioconda-recipes/blob/2b02c3db6400499d910bc5f297d23cb20c9db4f8/recipes/yacrd/build.sh
if [ "$(uname)" == "Darwin" ]; then

    # apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
    export HOME=`pwd`
    echo "HOME is $HOME"
    mkdir -p $HOME/.cargo/registry/index/
fi

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

# on osx we remove the built-in boost and make sure todepend on the system boost
pushd src
if [ "$(uname)" == "Darwin" ]; then
   rm -rf ./canu/src/utgcns/libboost/
fi
make clean && make -j$CPU_COUNT
popd

cp -rf bin/* $PREFIX/bin/
cp -rf lib/* $PREFIX/lib/
