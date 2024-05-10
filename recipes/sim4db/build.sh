#!/usr/bin/bash
set -ex
make install




mkdir -p $PREFIX
if [ `uname` == Darwin ]; then
    cp Darwin-amd64/bin/* $PREFIX/bin/
    cp Darwin-amd64/include/* $PREFIX/include/
    cp Darwin-amd64/lib/* $PREFIX/lib/
else
    COPY_ROOT="Linux-amd64"
    case $(uname -m) in
        arm64|aarch64) COPY_ROOT="Linux-aarch64" ;;
    esac
    cp $COPY_ROOT/bin/* $PREFIX/bin/
    cp $COPY_ROOT/include/* $PREFIX/include/
    cp $COPY_ROOT/lib/* $PREFIX/lib/
fi

