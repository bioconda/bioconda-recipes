#!/bin/bash
# Cria o setup.py dinamicamente
cat > setup.py << EOF
from setuptools import setup
setup(
    name="hymet",
    version="1.0.0",
    packages=["hymet"],
)
EOF
mkdir -p hymet
touch hymet/__init__.py
$PYTHON -m pip install . --no-deps -vv