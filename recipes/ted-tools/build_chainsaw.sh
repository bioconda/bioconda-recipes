#!/bin/bash
set -euxo pipefail

SHARE="${PREFIX}/share/ted-chainsaw"
SRC="ted_consensus_1.0/programs/chainsaw"
mkdir -p "${SHARE}/stride" "${PREFIX}/bin"

cp -r "${SRC}/get_predictions.py" "${SRC}/src" "${SRC}/saved_models" "${SHARE}/"

# stride is built from the tarball (stride.h is not in the repo tree); src/constants.py
# looks for it at <install dir>/stride/stride
STRIDE_BUILD="$(mktemp -d)"
tar -xzf "${SRC}/stride/stride.tgz" -C "${STRIDE_BUILD}"
# ARCH= : the Makefile names its output stride${ARCH}, and conda-build sets ARCH
make -C "${STRIDE_BUILD}" CC="${CC} ${CFLAGS}" FLAGS="${LDFLAGS} -lm -o" ARCH=
install -m 755 "${STRIDE_BUILD}/stride" "${SHARE}/stride/stride"

cat > "${PREFIX}/bin/chainsaw" <<EOF
#!/usr/bin/env bash
exec python "${SHARE}/get_predictions.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/chainsaw"
