#!/usr/bin/env bash
set -euo pipefail

# conda-build extracts the archive's outer directory before running this file.
for required in LICENSE RIASO/riaso/Cargo.toml RIASO/riaso/Cargo.lock RIASO/riaso/scripts/build_binary.sh RIASO/riaso/scripts/collect_libs.sh; do
    if [[ ! -e "${SRC_DIR}/${required}" ]]; then
        printf 'Missing source archive entry: %s\n' "${required}" >&2
        exit 1
    fi
done

cd "${SRC_DIR}/RIASO/riaso"
export CONDA_PREFIX="${PREFIX}"
export HDF5_DIR="${PREFIX}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
export CARGO_TARGET_DIR="${SRC_DIR}/riaso-cargo-target"
export CARGO_BUILD_JOBS="${CPU_COUNT:-2}"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"

# Reuse the upstream bundling implementation in a build-only copy. Avoid
# activating a named environment, and retain conda's compiler/Rust flags.
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
body = body.replace(command, command + ' --locked')
# Keep this next to collect_libs.sh because upstream resolves it via $0.
Path("scripts/.bioconda-build_binary.sh").write_text(
    '#!/usr/bin/env bash\nset -euo pipefail\n' + body, encoding="utf-8"
)
PY
bash scripts/.bioconda-build_binary.sh

# Install the complete dist tree privately, preserving its relative layout
# and symlinks. Do not invoke build_conda_package.sh: conda-build creates the
# final package and metadata from the files installed under PREFIX.
bundle="${PREFIX}/share/riaso"
mkdir -p "${PREFIX}/bin" "${bundle}"
cp -a dist/. "${bundle}/"
install -m 644 "${SRC_DIR}/LICENSE" "${bundle}/LICENSE"
chmod 755 "${bundle}/riaso" "${bundle}/bin/riaso"

# Keep bundled libraries private; the original launcher sets FONTCONFIG_FILE.
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

# Verify the installed tree before conda-build packages it.
env -i "${PREFIX}/bin/riaso" --version
env -i "${PREFIX}/bin/riaso" --HELP > /dev/null
