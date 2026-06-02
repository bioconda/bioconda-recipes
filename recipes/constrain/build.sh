#!/bin/bash
set -euxo pipefail

cd ConSTRain

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"

cargo build --release --bin ConSTRain

mkdir -p "${PREFIX}/bin"
cp target/release/ConSTRain "${PREFIX}/bin/ConSTRain"

mkdir -p "${PREFIX}/share/licenses/${PKG_NAME}"
cp ../LICENSE "${PREFIX}/share/licenses/${PKG_NAME}/LICENSE"

"${STRIP}" "${PREFIX}/bin/ConSTRain"