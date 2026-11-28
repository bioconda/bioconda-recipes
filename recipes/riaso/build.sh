#!/usr/bin/env bash
set -euo pipefail

if [[ "${target_platform}" == osx-* ]]; then
export MACOSX_DEPLOYMENT_TARGET=11.0
cd "${SRC_DIR}/RIASO/riaso"
case "${target_platform}" in
    osx-arm64) target=aarch64-apple-darwin ;;
    osx-64) target=x86_64-apple-darwin ;;
    *) echo 'This script requires an osx-64 or osx-arm64 target' >&2; exit 1 ;;
esac

export CARGO_HOME="${CARGO_HOME:-${SRC_DIR}/.cargo-home}"
mkdir -p "$CARGO_HOME"
export CARGO_HOME="$(cd "$CARGO_HOME" && pwd -P)"
export CARGO_TARGET_DIR="${SRC_DIR}/riaso-cargo-target"
export CARGO_BUILD_JOBS="${CPU_COUNT:-2}"
export HDF5_DIR="$PREFIX"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
export LIBRARY_PATH="${PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"
if [[ "$target" == aarch64-apple-darwin ]]; then
    export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="$CC"
else
    export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER="$CC"
fi

cargo build --release --locked --bin riaso --target "$target"
bundle="${PREFIX}/share/riaso"
mkdir -p "$PREFIX/bin" "$bundle/bin" "$bundle/lib" "$bundle/fonts" "$bundle/etc/fonts"
cp "$CARGO_TARGET_DIR/$target/release/riaso" "$bundle/bin/riaso"
chmod 755 "$bundle/bin/riaso"
# Let delocate resolve @rpath dependencies from the build environment.
# Re-scan copied dylibs so their transitive dependencies are bundled too.
for pass in {1..16}; do
    before=$(find "$bundle/lib" -type f | wc -l | tr -d ' ')
    DYLD_LIBRARY_PATH="${PREFIX}/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}" delocate-path --executable-path "$bundle/bin" -L lib "$bundle"
    after=$(find "$bundle/lib" -type f | wc -l | tr -d ' ')
    if [[ "$before" == "$after" ]]; then
        break
    fi
    if [[ "$pass" == 16 ]]; then
        echo 'Dynamic-library dependency collection did not converge' >&2
        exit 1
    fi
done

python - "$bundle" <<'PY'
from pathlib import Path
import re
import subprocess
import sys

root = Path(sys.argv[1])
for library in [root / "bin/riaso", *sorted((root / "lib").glob("*.dylib"))]:
    commands = subprocess.check_output(["otool", "-l", str(library)], text=True)
    versions = re.findall(r"cmd LC_BUILD_VERSION\b(?:(?!\n\s*Load command).)*?\bminos\s+(\d+(?:\.\d+)+)", commands, re.S)
    versions += re.findall(r"cmd LC_VERSION_MIN_MACOSX\b.*?\bversion\s+(\d+(?:\.\d+)+)", commands, re.S)
    if not versions:
        raise SystemExit(f"Cannot determine minimum macOS version: {library}")
    for version in versions:
        parts = tuple(map(int, version.split(".")))
        if (parts + (0, 0))[:3] > (11, 0, 0):
            raise SystemExit(f"{library} requires macOS {version}, expected <=11.0")
print("Verified bundled Mach-O deployment versions <= macOS 11.0")
PY
python - "$PREFIX" "$bundle" "$SRC_DIR" <<'PY'
from pathlib import Path
import shutil
import sys

prefix, bundle, source = map(Path, sys.argv[1:])
fonts = sorted((prefix / "fonts").glob("*.ttf"))
if not fonts:
    fonts = sorted((prefix / "share/fonts").rglob("*.ttf"))
if not fonts:
    raise SystemExit("No bundled fonts found")
for font in fonts:
    shutil.copy2(font, bundle / "fonts" / font.name)
(bundle / "etc/fonts/fonts.conf").write_text(
    '<?xml version="1.0"?>\n<fontconfig><dir prefix="relative">../../fonts</dir></fontconfig>\n',
    encoding="utf-8",
)
shutil.copy2(source / "LICENSE", bundle / "LICENSE")
PY

cat > "$bundle/riaso" <<'SH'
#!/bin/sh
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
export FONTCONFIG_FILE="$here/etc/fonts/fonts.conf"
exec "$here/bin/riaso" "$@"
SH
chmod 755 "$bundle/riaso"

cat > "$PREFIX/bin/riaso" <<'SH'
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
chmod 755 "$PREFIX/bin/riaso"
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != 1 ]]; then
    env -i HOME="$HOME" "$PREFIX/bin/riaso" --version
    env -i HOME="$HOME" "$PREFIX/bin/riaso" --HELP > /dev/null
fi

    exit 0
fi

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
