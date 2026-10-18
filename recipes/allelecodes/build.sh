#!/bin/bash
set -ex


mkdir -p $PREFIX/bin

# Fix python3.6 shebang
sed -i '1s|.*|#!/usr/bin/env python|' assignAlleleCodes_py3.6.py

# Copy the script to the conda bin directory
chmod +x assignAlleleCodes_py3.6.py
cp assignAlleleCodes_py3.6.py $PREFIX/bin/assignAlleleCodes
cp assignAlleleCodes_py3.6.py $PREFIX/bin/assignAlleleCodes_py3.6.py

# ensure backward compatibility with a symlink

echo "=== DONE WITH $0 ==="
