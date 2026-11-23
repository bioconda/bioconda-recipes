#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/hypergrass"

# Support conda cross-compiler prefixes (e.g., x86_64-conda-linux-gnu-cc) even when
# building source releases prior to direct $CC/$CXX probing inside native/eimdl-rs/build.rs.
SHIM_BIN="$(mktemp -d)"
trap 'rm -rf "${SHIM_BIN}"' EXIT
if [[ -n "${CC:-}" ]] && ! command -v gcc >/dev/null 2>&1; then
  ln -s "$(command -v "${CC}")" "${SHIM_BIN}/gcc"
fi
if [[ -n "${CXX:-}" ]] && ! command -v g++ >/dev/null 2>&1; then
  ln -s "$(command -v "${CXX}")" "${SHIM_BIN}/g++"
fi
if [[ -n "${AR:-}" ]] && ! command -v ar >/dev/null 2>&1; then
  ln -s "$(command -v "${AR}")" "${SHIM_BIN}/ar"
fi
export PATH="${SHIM_BIN}:${PATH}"

# 1. Build zero-crate Native C23/C++23/Rust 2024 engine (`eimdl`) completely offline
export CARGO_HOME="${CARGO_HOME:-${PWD}/.cargo}"
export CARGO_NET_OFFLINE=true
(
  cd native/eimdl-rs
  if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
    cargo build --release --offline --target "${CARGO_BUILD_TARGET}"
    BIN_PATH="target/${CARGO_BUILD_TARGET}/release/eimdl"
  else
    cargo build --release --offline
    BIN_PATH="target/release/eimdl"
  fi
  install -m 0755 "${BIN_PATH}" "${PREFIX}/bin/eimdl"
)

# 2. Build zero-dependency Java 25 LTS CLI (`hypergrass.jar`) + relocatable wrappers
JAVA_OUT="${PWD}/_bioconda_java_classes"
rm -rf "${JAVA_OUT}"
mkdir -p "${JAVA_OUT}"
javac --release 25 -Xlint:none -d "${JAVA_OUT}" src/hypergrass/*.java
jar --create \
  --file "${PREFIX}/share/hypergrass/hypergrass.jar" \
  --main-class hypergrass.HyperGraSS \
  -C "${JAVA_OUT}" .
rm -rf "${JAVA_OUT}"

cat > "${PREFIX}/bin/hypergrass" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec java -cp "${ROOT_DIR}/share/hypergrass/hypergrass.jar" hypergrass.HyperGraSS "$@"
EOF
chmod 0755 "${PREFIX}/bin/hypergrass"

cat > "${PREFIX}/bin/eimdl-java" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec java -cp "${ROOT_DIR}/share/hypergrass/hypergrass.jar" hypergrass.EimdlCli "$@"
EOF
chmod 0755 "${PREFIX}/bin/eimdl-java"
