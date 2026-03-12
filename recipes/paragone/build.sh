#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

sed -i.bak 's|setuptools.find_packages(),|setuptools.find_namespace_packages(where="."),|' setup.py
rm -rf *.bak

# Install ParaGone
${PYTHON} -m pip install --no-deps --no-build-isolation --no-cache-dir . -vvv

# Install TAPER:
git clone https://github.com/chaoszhang/TAPER.git
chmod 755 TAPER/correction_multi.jl
cp -f TAPER/correction_multi.jl ${PREFIX}/bin
