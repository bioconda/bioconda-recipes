#!/bin/bash
set -euxo pipefail

cd ConSTRain

cargo build --release --bin ConSTRain

mkdir -p "${PREFIX}/bin"
cp target/release/ConSTRain "${PREFIX}/bin/ConSTRain"

"${STRIP}" "${PREFIX}/bin/ConSTRain"