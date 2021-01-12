#!/bin/sh
set -e

mkdir -p "${PREFIX}/bin"
mv ./scripts/* "${PREFIX}/bin/"
mv ./* "${PREFIX}/bin/"
pip install datasketch

exit 0
