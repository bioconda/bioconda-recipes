#!/bin/bash
set -euo pipefail
mkdir -p ${PREFIX}/bin
install -m 755 isopedia "$PREFIX/bin/"
install -m 755 isopedia-tools "$PREFIX/bin/"
install -m 755 isopedia-splice-viz.py "$PREFIX/bin/"
mkdir -p "$PREFIX/share/isopedia"
install -m 644 isopedia-splice-viz-temp.html "$PREFIX/share/isopedia/"
