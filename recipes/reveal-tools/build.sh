#!/bin/bash

set -euo pipefail

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/reveal"

cp src/*.py "$PREFIX/lib/reveal/"
cp src/*.R  "$PREFIX/lib/reveal/"

# Create the REVEAL entry point
cat > "$PREFIX/bin/REVEAL" << 'EOF'
#!/bin/bash
exec python "$CONDA_PREFIX/lib/reveal/reveal.py" "$@"
EOF
chmod +x "$PREFIX/bin/REVEAL"
