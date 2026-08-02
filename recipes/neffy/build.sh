#!/usr/bin/env bash
set -e
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case $(uname -m) in
    aarch64)
    sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
    ;;
    arm64)
    sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
    ;;
esac
rm -f *.bak

make CC="${CXX}" -j"${CPU_COUNT}"

# Now build and install
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
