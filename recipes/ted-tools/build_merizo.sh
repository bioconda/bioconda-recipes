#!/bin/bash
set -euxo pipefail

SHARE="${PREFIX}/share/ted-merizo"
SRC="ted_consensus_1.0/programs/merizo"
mkdir -p "${SHARE}/weights" "${PREFIX}/bin"

cp -r "${SRC}/predict_afdb.py" "${SRC}/model" "${SHARE}/"
# predict_afdb.py loads every *.pt in <script dir>/weights
cp merizo_weights/weights_part_*.pt "${SHARE}/weights/"

cat > "${PREFIX}/bin/ted-merizo" <<EOF
#!/usr/bin/env bash
exec python "${SHARE}/predict_afdb.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/ted-merizo"
