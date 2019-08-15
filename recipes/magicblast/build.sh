#!/bin/bash
set -euxo pipefail

mkdir -p $PREFIX/bin

# the binary expects libbz2.so.1, but the correct name is libbz2.so.1.0
if [[ $(uname) = Linux ]] ; then
    patchelf --replace-needed libbz2.so.1 libbz2.so.1.0 bin/magicblast
fi

mv bin/magicblast $PREFIX/bin

