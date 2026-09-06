#!/bin/bash

set -euo pipefail

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/reveal"

cp src/*.py "$PREFIX/lib/reveal/"
cp src/*.R  "$PREFIX/lib/reveal/"

# Create the REVEAL entry point
cat > "$PREFIX/bin/REVEAL" << 'EOF'
#!/bin/bash
# Resolve the install prefix from the wrapper's own location, so REVEAL works
# when called by absolute path or from a different active environment.
_dir="$(cd "$(dirname "$0")" && pwd)"
exec "$_dir/python" "$_dir/../lib/reveal/reveal.py" "$@"
EOF
chmod +x "$PREFIX/bin/REVEAL"
