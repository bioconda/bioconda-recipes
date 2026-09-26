#!/bin/bash
# conda-build script: install mirdeep-p3 into the conda package
set -e

# conda-build strips a single top-level directory from an archive source.  It has
# always produced $SRC_DIR/mirdeep-p3 for the upstream tarball, but with a second
# (folder:-placed) source in the mix, be explicit about where the tree landed.
ROOT="$SRC_DIR"
for cand in "$SRC_DIR" "$SRC_DIR/mirdeep-p3-$PKG_VERSION"; do
    if [ -f "$cand/mirdeep-p3" ] && [ -d "$cand/src" ]; then
        ROOT="$cand"
        break
    fi
done
if [ ! -f "$ROOT/mirdeep-p3" ]; then
    echo "ERROR: mirdeep-p3 launcher not found under $SRC_DIR" >&2
    exit 1
fi

# Install the whole project tree under $PREFIX/share/mirdeep-p3
PROJ="$PREFIX/share/mirdeep-p3"
mkdir -p "$PROJ"
cp "$ROOT/mirdeep-p3" "$PROJ/mirdeep-p3"
cp -r "$ROOT/src" "$PROJ/src"
cp -r "$ROOT/bin" "$PROJ/bin"
cp -r "$ROOT/scripts" "$PROJ/scripts"
cp -r "$ROOT/data" "$PROJ/data"
chmod 755 "$PROJ/mirdeep-p3"

# Bundled search databases (second source, extracted with folder: data-index).
# conda-build strips the single top-level directory of an archive source, so the
# tarball's leading `index/` is removed and the files land directly in
# $SRC_DIR/data-index/.  Keep the nested and bare variants as fallbacks in case
# that behaviour differs between conda-build versions.
# mirdeep-p3 hard-codes <project_root>/data/index/{rfam_index,mature_index}, so
# these must end up inside the installed tree.  Fail loudly rather than ship a
# package whose `identification` step cannot run.
IDX=""
for cand in "$SRC_DIR/data-index" "$SRC_DIR/data-index/index" "$SRC_DIR/index"; do
    if [ -e "$cand/rfam_index.1.ebwt" ] && [ -e "$cand/mature_index.1.ebwt" ]; then
        IDX="$cand"
        break
    fi
done
if [ -z "$IDX" ]; then
    echo "ERROR: bundled index not found under $SRC_DIR (looked in data-index, data-index/index, index)" >&2
    exit 1
fi
mkdir -p "$PROJ/data/index"
cp -r "$IDX/." "$PROJ/data/index/"
echo "installed $(ls -1 "$PROJ/data/index" | wc -l) index file(s) from $IDX"

# Create the `mirdeep-p3` command in bin/
mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/mirdeep-p3" <<EOF
#!/usr/bin/env bash
exec "$PROJ/mirdeep-p3" "\$@"
EOF
chmod 755 "$PREFIX/bin/mirdeep-p3"
