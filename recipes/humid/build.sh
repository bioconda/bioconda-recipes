#!/bin/bash
set -eu -o pipefail

case $(uname -s) in
    Darwin)
      sed -i.bak 's|-fcoroutines-ts||' src/Makefile
      ;;
esac

sed -i.bak 's|-O2|-O3|' src/Makefile
rm -f src/*.bak

cd src

make CXX="${CXX}" -j"${CPU_COUNT}"

make install
