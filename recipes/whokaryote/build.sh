#!/bin/bash

set -exuo pipefail

# Add missing shebang line to bin/whokaryote.py
cp bin/whokaryote.py bin/whokaryote.py.bak
echo "#!/usr/bin/env python3" | cat - bin/whokaryote.py.bak > bin/whokaryote.py

# Install using pip
python -m pip install .
