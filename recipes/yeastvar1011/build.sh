#!/bin/sh
set -eu
: "${PREFIX:?Conda build PREFIX is required}"
: "${SRC_DIR:?Conda build SRC_DIR is required}"
: "${RECIPE_DIR:?Conda build RECIPE_DIR is required}"
cd "$SRC_DIR"
app_dir="$PREFIX/share/yeastvar1011"
mkdir -p "$app_dir" "$PREFIX/bin"
for directory in dist scripts docs; do
  test -d "$directory"
  cp -R "$directory" "$app_dir/"
done
# Install workflow sources and examples, never a user's active samples/config or outputs.
mkdir -p "$app_dir/analysis"
for file in environment.yaml config.example.yaml samples.example.tsv run.sh; do
  test -f "analysis/$file"
  cp "analysis/$file" "$app_dir/analysis/"
done
if [ -f analysis/README.md ]; then cp analysis/README.md "$app_dir/analysis/"; fi
for directory in analysis/workflow analysis/profiles analysis/tests; do
  if [ -d "$directory" ]; then
    find "$directory" -type f \( -name '*.py' -o -name '*.yaml' -o -name '*.yml' -o -name '*.sh' -o -name Snakefile \) | while IFS= read -r file; do
      mkdir -p "$app_dir/$(dirname "$file")"
      cp "$file" "$app_dir/$file"
    done
  fi
done
for file in package.json package-lock.json README.md LICENSE THIRD_PARTY_NOTICES.md DATA_SOURCES.md CITATION.cff; do
  test -f "$file"
  cp "$file" "$app_dir/"
done
# Keep the vendored licenses and readable citeproc source with the static site.
test -s "$app_dir/dist/vendor/katex/fonts/OFL.txt"
test -s "$app_dir/dist/vendor/citations/CPAL-1.0.txt"
test -s "$app_dir/dist/vendor/citations/citeproc.js"
install -m 755 "$RECIPE_DIR/yeastvar1011.cjs" "$PREFIX/bin/yeastvar1011"
install -m 755 "$RECIPE_DIR/yeastvar1011-doctor.cjs" "$PREFIX/bin/yeastvar1011-doctor"
