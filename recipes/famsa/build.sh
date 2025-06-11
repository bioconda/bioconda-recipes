#!/bin/bash

set -xe

case $(uname -m) in
    aarch64 | arm64)
        ARCH_OPTS="PLATFORM=arm8"
        ;;
    *)
        ARCH_OPTS=""
        ;;
esac

make famsa ${ARCH_OPTS} -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install famsa "${PREFIX}/bin"
