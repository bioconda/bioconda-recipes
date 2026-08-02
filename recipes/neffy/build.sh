#!/usr/bin/env bash
set -e
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# If you are making a g++ symlink:
#mkdir -p ./mybin
#ln -s "$(command -v $CXX)" ./mybin/g++
#export PATH="$(pwd)/mybin:$PATH"

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
sed -i.bak 's|-O3|-O3 -D_LIBCPP_DISABLE_AVAILABILITY|' Makefile
sed -i.bak "s|CC=g++|CC=${CXX}|" Makefile

case $(uname -m) in
    aarch64)
    sed -i.bak 's|-O3|-O3 -march=armv8-a|' Makefile
    ;;
    arm64)
    sed -i.bak 's|-O3|-O3 -march=armv8.4-a|' Makefile
    ;;
    x86_64)
    sed -i.bak 's|-O3|-O3 -march=x86-64-v3|' Makefile
    ;;
esac

rm -f *.bak

# Now build and install
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
