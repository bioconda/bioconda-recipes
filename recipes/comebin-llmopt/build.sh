#!/usr/bin/env bash
set -euo pipefail
# Install into share/ so this package does not clash with the `comebin`
# package's run_comebin.sh; only `comebin-llmopt` goes on PATH.
share="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${share}" "${PREFIX}/bin"
cp -r COMEBin auxiliary LICENSE.txt NOTICE.md "${share}/"
chmod a+x "${share}"/auxiliary/*.pl "${share}/COMEBin/run_comebin.sh" "${share}/COMEBin/comebin-llmopt"
ln -s "../share/${PKG_NAME}/COMEBin/comebin-llmopt" "${PREFIX}/bin/comebin-llmopt"
