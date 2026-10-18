#!/bin/bash
set -euo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 build/HAPCUT2 build/extractHAIRS "${PREFIX}/bin"

if [[ "$(uname -s)" == "Linux" ]]; then
	ln -sf HAPCUT2 ${PREFIX}/bin/hapcut2
fi

for script in LinkFragments.py calculate_haplotype_statistics.py; do
	install -v -m 0755 utilities/${script} "${PREFIX}/bin"
done
