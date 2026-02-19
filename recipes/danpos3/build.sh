#!/bin/bash
mkdir -p $PREFIX/bin
cp *.py $PREFIX/bin/
for f in $PREFIX/bin/*.py; do
    sed -i '1s|.*|#!'"$PYTHON"'|' "$f"
    chmod +x "$f"
done