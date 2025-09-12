#!/bin/bash
set -ex

# instalar con pip
$PYTHON -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir

# Wrap scripts from sierralocal and add shebang
for f in sierralocal/*.py; do
    name=$(basename $f .py)
    cat > ${PREFIX}/bin/$name << EOF
#!/usr/bin/env bash
exec "$PYTHON" -m sierralocal.$name "\$@"
EOF
    chmod +x ${PREFIX}/bin/$name
done

# Wrap scripts from scripts/ and add shebang
for f in scripts/*.py; do
    name=$(basename $f .py)
    cp "$f" "$PREFIX/bin/$name.py"
    cat > "$PREFIX/bin/$name" << EOF
#!/usr/bin/env bash
exec "$PYTHON" "$PREFIX/bin/$name.py" "\$@"
EOF
    chmod +x "$PREFIX/bin/$name" "$PREFIX/bin/$name.py"
done