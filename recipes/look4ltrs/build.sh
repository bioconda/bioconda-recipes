#!/bin/bash
set -ex

# CMake build of the look4ltrs target (C++17 + OpenMP).
cmake -S . -B build_conda \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"
cmake --build build_conda --target look4ltrs -j "${CPU_COUNT}"

mkdir -p "$PREFIX/bin"
LB="$(find . -name look4ltrs -type f -perm -u+x | head -1)"
[ -n "$LB" ] || { echo "look4ltrs binary not produced" >&2; exit 1; }
install -m 0755 "$LB" "$PREFIX/bin/look4ltrs"

# Ship the LTR-library builder used by the Pan_TE pipeline at the path it expects
# (Pan_TE resolves it as <pan_te_share>/../submodule/Look4LTRs/build_ltr_library.py;
# installing a copy here lets a standalone look4ltrs install also carry it).
if [ -f build_ltr_library.py ]; then
    mkdir -p "$PREFIX/share/Look4LTRs"
    install -m 0644 build_ltr_library.py "$PREFIX/share/Look4LTRs/build_ltr_library.py"
fi
