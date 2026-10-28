#!/bin/bash
set -euxo pipefail

$PYTHON -m pip install --no-deps --no-build-isolation --no-cache-dir -vv \
    "metacat-${PKG_VERSION}-py3-none-any.whl"

cd "${SP_DIR}/MetaCAT"

# The wheel vendors FragGeneScan (plus its training data), hmmsearch and mash;
# use the conda packages instead.
rm -f FragGeneScan-* hmmsearch-* mash-*
rm -rf train

# Keep only the ctypes libraries for the platform being built.
rm -f ./*windows*
if [ "${target_platform}" = "osx-arm64" ]; then
    rm -f ./*-linux-x86_64 ./*-linux-x86_64.so
else
    rm -f ./*-darwin-arm64 ./*-darwin-arm64.dylib
fi

# Resolve the unvendored tools on PATH rather than inside the package.
sed -i.bak \
    -e "s|c\.findBinary('FragGeneScan')|'FragGeneScan'|" \
    -e "s|c\.findBinary('hmmsearch')|'hmmsearch'|" \
    -e "s|c\.findBinary('mash')|'mash'|" \
    -e "s|Default: internal FragGeneScan\.|Default: FragGeneScan on PATH.|" \
    -e "s|Default: internal hmmsearch\.|Default: hmmsearch on PATH.|" \
    -e "s|Default: internal mash\.|Default: mash on PATH.|" \
    __init__.py
rm -f __init__.py.bak

# Fail loudly if a future version looks up a vendored binary we did not patch.
if grep -q findBinary __init__.py; then
    echo "ERROR: __init__.py still resolves a vendored binary" >&2
    exit 1
fi

# pip byte-compiled the unpatched sources; let conda-build redo it.
rm -rf __pycache__

# Drop the deleted files from the wheel's RECORD.
$PYTHON - <<'END'
import os

sp_dir = os.environ['SP_DIR']
record = os.path.join(sp_dir, 'metacat-%s.dist-info' % os.environ['PKG_VERSION'], 'RECORD')
with open(record) as handle:
    lines = [i for i in handle if os.path.exists(os.path.join(sp_dir, i.split(',')[0]))]
with open(record, 'w') as handle:
    handle.writelines(lines)
END
