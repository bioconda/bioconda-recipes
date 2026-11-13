#!/bin/bash
set -euxo pipefail

# macOS: replace conda's otool/install_name_tool (including the llvm-* names
# conda-build calls) with Xcode's. See conda/conda-build#4392.
if [[ "${target_platform:-}" == osx-* ]]; then
  for toolname in otool install_name_tool; do
    sys_tool="$(xcrun --find "${toolname}" 2>/dev/null || echo "/Library/Developer/CommandLineTools/usr/bin/${toolname}")"
    for tool in "${BUILD_PREFIX}/bin/"*apple*-"${toolname}" "${BUILD_PREFIX}/bin/llvm-${toolname}"; do
      if [[ -f "${tool}" && ! -e "${tool}.bak" ]]; then
        mv "${tool}" "${tool}.bak"
        ln -sf "${sys_tool}" "${tool}"
      fi
    done
  done
fi

export CARGO_PROFILE_RELEASE_DEBUG=false
export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
