#!/usr/bin/env bash
set -euxo pipefail

cd "${SRC_DIR}/LOSAT"

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
cargo build --release --locked --bin LOSAT --verbose

binary="target/release/LOSAT"
if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
    binary="target/${CARGO_BUILD_TARGET}/release/LOSAT"
fi
test -x "${binary}"

install -d "${PREFIX}/bin"
install -m 0755 "${binary}" "${PREFIX}/bin/losat"
