#!/bin/bash
# Cria a estrutura mínima de pacote Python
mkdir -p hymet
touch hymet/__init__.py

# Gera o setup.py dinamicamente
cat > setup.py << EOF
from setuptools import setup

setup(
    name="hymet",
    version="{{ version }}",
    packages=["hymet"],
    install_requires=[
        "pandas",
        "numpy",
        "biopython",
        "tqdm"
    ],
)
EOF

# Instala o pacote
${PYTHON} -m pip install . --no-deps -vv