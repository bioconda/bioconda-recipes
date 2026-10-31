#!/usr/bin/env bash
set -euo pipefail

for required in LICENSE RIASO/riaso/Cargo.toml RIASO/riaso/Cargo.lock RIASO/riaso/scripts/build_binary.sh RIASO/riaso/scripts/collect_libs.sh; do
    if [[ ! -e "${SRC_DIR}/${required}" ]]; then
        printf 'Missing source archive entry: %s\n' "${required}" >&2
        exit 1
    fi
done

cd "${SRC_DIR}/RIASO/riaso"
export CARGO_HOME="${CARGO_HOME:-${SRC_DIR}/.cargo-home}"
mkdir -p "${CARGO_HOME}"
export CARGO_HOME="$(cd "${CARGO_HOME}" && pwd -P)"
export CONDA_PREFIX="${PREFIX}"
export HDF5_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
export CARGO_TARGET_DIR="${SRC_DIR}/riaso-cargo-target"
export CARGO_BUILD_JOBS="${CPU_COUNT:-2}"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"

printf 'Rust linker: %s\n' "${CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER}"
printf 'Compiler sysroot: %s\n' "$("${CC}" --print-sysroot)"
glibc_macros="$("${CC}" -dM -E -include features.h - </dev/null)"
if ! grep -qx '#define __GLIBC__ 2' <<< "${glibc_macros}" || \
   ! grep -qx '#define __GLIBC_MINOR__ 17' <<< "${glibc_macros}"; then
    printf 'Expected compiler sysroot glibc 2.17\n' >&2
    exit 1
fi

python - <<'PY'
from pathlib import Path

source = Path("scripts/build_binary.sh").read_text(encoding="utf-8")
start = '# --- 1. Let pkg-config locate'
end = '# --- 3. Put the target directory'
flags_start = '# --- 2. Distribution-safe compile options ---'
for marker in (start, flags_start, end):
    if source.count(marker) != 1:
        raise SystemExit(f"Upstream build script changed: expected one {marker!r}")
body = source[source.index(start):]
body = body[:body.index(flags_start)] + body[body.index(end):]
command = 'cargo build --release --bin riaso'
if body.count(command) != 1:
    raise SystemExit("Upstream cargo build command changed; review the recipe")
body = body.replace(command, command + ' --locked --target x86_64-unknown-linux-gnu')
artifact = '$CARGO_TARGET_DIR/release/riaso'
if body.count(artifact) != 1:
    raise SystemExit("Upstream binary copy path changed; review the recipe")
body = body.replace(artifact, '$CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/riaso')
Path("scripts/.bioconda-build_binary.sh").write_text(
    '#!/usr/bin/env bash\nset -euo pipefail\n' + body, encoding="utf-8"
)
PY
bash scripts/.bioconda-build_binary.sh

bundle="${PREFIX}/share/riaso"
mkdir -p "${PREFIX}/bin" "${bundle}"
cp -a dist/. "${bundle}/"
install -m 644 "${SRC_DIR}/LICENSE" "${bundle}/LICENSE"
chmod 755 "${bundle}/riaso" "${bundle}/bin/riaso"

cat > "${PREFIX}/bin/riaso" <<'SH'
#!/bin/sh
set -eu
self=$0
case "$self" in
    */*) ;;
    *) self=$(command -v "$self") ;;
esac
bindir=$(CDPATH= cd -- "$(dirname -- "$self")" && pwd -P)
exec "$bindir/../share/riaso/riaso" "$@"
SH
chmod 755 "${PREFIX}/bin/riaso"

env -i "${PREFIX}/bin/riaso" --version
env -i "${PREFIX}/bin/riaso" --HELP > /dev/null
