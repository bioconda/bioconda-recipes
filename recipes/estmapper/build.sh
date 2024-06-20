#!/bin/bash

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'
CXXFLAGS="${CXXFLAGS} -std=c++03" \
    make install

if [ "$(uname)" = Darwin ]; then
    cp Darwin-amd64/bin/* ${PREFIX}/bin/
    cp Darwin-amd64/include/* ${PREFIX}/include/
    cp Darwin-amd64/lib/* ${PREFIX}/lib/
else
    COPY_ROOT="Linux-amd64"
    case $(uname -m) in
        arm64|aarch64) COPY_ROOT="Linux-aarch64" ;;
    esac
    cp $COPY_ROOT/bin/* $PREFIX/bin/
    cp $COPY_ROOT/include/* $PREFIX/include/
    cp $COPY_ROOT/lib/* $PREFIX/lib/
fi
