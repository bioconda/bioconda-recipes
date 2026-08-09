#!/usr/bin/env bash
set -euxo pipefail

export CARGO_BUILD_JOBS="${CPU_COUNT:-1}"

# If conda sets a default target, cargo will build into target/$CARGO_BUILD_TARGET/...
target_args=()
binpath="target/release/itsxrust"
if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
  target_args=(--target "${CARGO_BUILD_TARGET}")
  binpath="target/${CARGO_BUILD_TARGET}/release/itsxrust"
fi

cargo build --release --locked -j "${CARGO_BUILD_JOBS}" "${target_args[@]}"

# Debug (optional but helpful)
ls -lah "$(dirname "${binpath}")"

install -d "${PREFIX}/bin"
install -m 0755 "${binpath}" "${PREFIX}/bin/itsxrust"
install -d "${PREFIX}/share/itsxrust/hmm"
install -m 0644 "${SRC_DIR}/data/hmm/F.hmm" "${PREFIX}/share/itsxrust/hmm/F.hmm"
