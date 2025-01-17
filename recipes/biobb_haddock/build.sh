#!/usr/bin/env bash

echo "Python version:"
python --version
echo "Pip version:"
pip --version
echo "Pip index:"
pip config list

python3 -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
python3 -m pip install haddock3 --no-deps --no-cache-dir