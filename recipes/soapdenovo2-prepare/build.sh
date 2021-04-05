#!/bin/sh
set -x -e

if [[ ${target_platform} == osx.* ]]; then
    export ARCHFLAGS="-Wno-error=unused-command-line-argument-hard-error-in-future"
    export CFLAGS="${CFLAGS} -Qunused-arguments"
    export CPPFLAGS="${CPPFLAGS} -Qunused-arguments"
fi

make CC="${CC} -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install finalFusion "${PREFIX}/bin/"
