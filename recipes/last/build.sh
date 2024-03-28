#!/usr/bin/env bash

set -xe

ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH_FLAGS="-msse4" ;;
    *) ARCH_FLAGS="" ;;
esac

make install CXXFLAGS="$CXXFLAGS ${ARCH_FLAGS} -pthread" prefix=$PREFIX