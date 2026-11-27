#!/bin/bash
set -euxo pipefail

SHARE="${PREFIX}/share/ted-unidoc"
SRC="ted_consensus_1.0/programs/unidoc_latest"
mkdir -p "${SHARE}/bin" "${PREFIX}/bin"

cp "${SRC}/Run_UniDoc_from_scratch_structure_afdb.py" "${SHARE}/"

# the script expects UniDoc_struct and stride in <script dir>/bin
# flags match setup.sh (-ffast-math can change domain boundaries, so keep it)
${CXX} ${CXXFLAGS} -std=c++11 -O3 -ffast-math -o "${SHARE}/bin/UniDoc_struct" "${SRC}/src/UniDoc_struct.cpp" ${LDFLAGS} -lm

STRIDE_BUILD="$(mktemp -d)"
tar -xzf ted_consensus_1.0/programs/chainsaw/stride/stride.tgz -C "${STRIDE_BUILD}"
# ARCH= : the Makefile names its output stride${ARCH}. This way ${ARC} is an empty string
make -C "${STRIDE_BUILD}" CC="${CC} ${CFLAGS}" FLAGS="${LDFLAGS} -lm -o" ARCH=
install -m 755 "${STRIDE_BUILD}/stride" "${SHARE}/bin/stride"

cat > "${PREFIX}/bin/ted-unidoc" <<EOF
#!/usr/bin/env bash
exec python "${SHARE}/Run_UniDoc_from_scratch_structure_afdb.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/ted-unidoc"
