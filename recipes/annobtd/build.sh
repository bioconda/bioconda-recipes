#!/bin/bash
# Install the scripts and tables under share/annobtd and put two commands on PATH.
# The scripts locate each other relative to the annoBTD root, so the tree is copied
# as is; ANNOBTD_REFDB (default share/annobtd/refdb) says where the database goes.
set -euo pipefail
DEST="$PREFIX/share/annobtd"
mkdir -p "$DEST" "$PREFIX/bin"
cp -R annobtd.sh fetch_refdb.sh pipeline guides refdb_build tables tools third_party test LICENSE.txt README.md "$DEST/"
rm -rf "$DEST/test/gb_cache" "$DEST/test/archive" "$DEST"/test/results*
chmod +x "$DEST"/*.sh "$DEST"/pipeline/*.sh "$DEST"/guides/*.sh "$DEST"/refdb_build/*.sh "$DEST"/test/*.sh
cat > "$PREFIX/bin/annobtd" <<'W'
#!/bin/bash
exec "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/../share/annobtd/annobtd.sh" "$@"
W
cat > "$PREFIX/bin/annobtd-fetch-refdb" <<'W'
#!/bin/bash
exec "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/../share/annobtd/fetch_refdb.sh" "$@"
W
chmod +x "$PREFIX/bin/annobtd" "$PREFIX/bin/annobtd-fetch-refdb"
