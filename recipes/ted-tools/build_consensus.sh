#!/bin/bash
set -euxo pipefail

SHARE="${PREFIX}/share/ted-consensus"
SRC="ted_consensus_1.0/scripts"
mkdir -p "${SHARE}" "${PREFIX}/bin"

# get_consensus.py imports domain_consensus and score_utils from its own dir
cp "${SRC}/get_consensus.py" "${SRC}/domain_consensus.py" "${SRC}/score_utils.py" "${SHARE}/"

cat > "${PREFIX}/bin/consensus" <<EOF
#!/usr/bin/env bash
exec python "${SHARE}/get_consensus.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/consensus"
