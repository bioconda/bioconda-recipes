#!/bin/bash
set -ex

# The Look4LTRs helper is supplied at runtime by the look4ltrs dependency
# ($PREFIX/share/Look4LTRs/build_ltr_library.py); no third-party source tree is
# vendored into the Pan_TE package.
SRC="$SRC_DIR/pan_te"
PKG="$PREFIX/share/pan_te"

mkdir -p "$PKG" "$PREFIX/bin"

# --- 1. install the pipeline tree (scripts + python subpackages) into share/pan_te ---
cp -r "$SRC/bin/." "$PKG/"

# strip caches / logs / local tooling config / dev-only scaffolding that should never ship
find "$PKG" -type d \( -name '__pycache__' -o -name '.claude' -o -name 'tests' \) \
    -prune -exec rm -rf {} + 2>/dev/null || true
find "$PKG" -type f \( -name '*.pyc' -o -name '*.log' -o -name '*.DONE' \) -delete 2>/dev/null || true
rm -rf "$PKG/Refiner/cache" "$PKG/Refiner/checkpoints" "$PKG/Refiner_mdl/checkpoints" 2>/dev/null || true

# ensure the script entry points are executable (cp usually preserves this, be explicit)
for f in Pan_TE clean_seq_fast index LTR_detect build_mdl run_Classifier renameTE \
         Combine_for_Two process_for_classify.py decode_gfa.pl; do
    [ -e "$PKG/$f" ] && chmod 0755 "$PKG/$f" || true
done

# --- 2. PATH wrapper. A plain symlink would break Pan_TE: it uses
#        os.path.dirname(os.path.abspath(__file__)) (NOT realpath), so the symlink target
#        dir would be wrong. A wrapper that execs the real script keeps __file__ correct. ---
cat > "$PREFIX/bin/Pan_TE" <<'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$DIR/share/pan_te/Pan_TE" "$@"
EOF
chmod 0755 "$PREFIX/bin/Pan_TE"

# --- 3. post-install data fetcher ---
install -m 0755 "$RECIPE_DIR/pan_te-setup-data" "$PREFIX/bin/pan_te-setup-data"
