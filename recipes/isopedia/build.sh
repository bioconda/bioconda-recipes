#!/bin/bash

pwd && ls -l
mkdir -p $PREFIX/bin
tar -xzvf ./isopedia-{{ version }}.linux.tar.gz && rm -rf ./isopedia-{{ version }}.linux.tar.gz || echo "skip extract"
find . -maxdepth 2 -type f -exec install -m 0755 {} $PREFIX/bin/ \;
chmod +x $PREFIX/bin/isopedia-splice-viz.py
chmod +x $PREFIX/bin/isopedia
chmod +x $PREFIX/bin/isopedia-tools
