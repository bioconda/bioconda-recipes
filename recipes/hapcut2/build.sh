#!/bin/bash
set -euo pipefail

make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
mkdir ${PREFIX}/bin
cp -p build/HAPCUT2 build/extractHAIRS ${PREFIX}/bin/

if [ $(uname) == Linux ]; then
	ln -s HAPCUT2 ${PREFIX}/bin/hapcut2
fi
for script in LinkFragments.py calculate_haplotype_statistics.py; do
  cp -p utilities/${script} ${PREFIX}/bin
  chmod +x ${PREFIX}/bin/${script}
done
