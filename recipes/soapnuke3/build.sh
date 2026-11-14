#!/usr/bin/env bash
set -euo pipefail

export TMPDIR="$SRC_DIR/.scratch/tmp"
mkdir -p "$TMPDIR"
# Native C++ compilation must use the Conda zlib headers and libraries.
export CPATH="$PREFIX/include${CPATH:+:$CPATH}"
export LIBRARY_PATH="$PREFIX/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
# CMake's explicit CMAKE_AR setting needs the archiver's absolute path.
export AR="$(command -v "$AR")"

./scripts/cargo.sh build --release --locked --offline --jobs "${CPU_COUNT:-2}"
./scripts/cargo.sh test --release --locked --offline --jobs "${CPU_COUNT:-2}" --lib -- --test-threads=1

binary=target/release/SOAPnuke
if [[ -n "${CARGO_BUILD_TARGET:-}" ]]; then
    binary="target/$CARGO_BUILD_TARGET/release/SOAPnuke"
fi
python3 tests/check_cli.py --binary "$binary" --threads 2 --out .scratch/tmp/conda-cli
python3 tests/check_modules.py --binary "$binary" --threads 2 --out .scratch/tmp/conda-modules
python3 tests/check_adapter_overlap.py --binary "$binary" --out .scratch/tmp/conda-overlap
install -Dm755 "$binary" "$PREFIX/bin/SOAPnuke"

python3 - <<'PY'
from pathlib import Path

with Path('THIRD_PARTY_LICENSES.txt').open('w') as output:
    for folder in ['vendor', 'soapnuke-rs/third_party']:
        for path in sorted(Path(folder).rglob('*')):
            if path.is_file() and path.name.upper().startswith(('LICENSE', 'COPYING', 'NOTICE')):
                output.write('\n' + str(path) + '\n' + '=' * 72 + '\n')
                output.write(path.read_text(errors='replace') + '\n')
PY
