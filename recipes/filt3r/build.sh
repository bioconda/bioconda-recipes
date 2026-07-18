#!/bin/bash
set -euo pipefail

# FiLT3r builds a single C++ binary via a plain Makefile. The Makefile derives
# CXX/CC from the environment (conda's compilers), so no toolchain patching is
# needed. It hardcodes -O3 in CXXFLAGS/LDFLAGS and links zlib (-lz).
#
# The Makefile stamps a version string into the JSON output via GIT_SHA1, which
# it computes from `git log`. The source tarball has no .git directory, so we
# inject the packaged version explicitly to keep the reported version meaningful.
make -j"${CPU_COUNT:-1}" \
    CXX="${CXX}" CC="${CC}" \
    GIT_SHA1="${PKG_VERSION}"

mkdir -p "${PREFIX}/bin"
install -m 0755 filt3r "${PREFIX}/bin/filt3r"

# Ship the bundled FLT3 exon 14-15 reference so users have a working default.
mkdir -p "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
cp data/flt3_exon14-15.fa "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/"
