#!/bin/sh
set -e

echo sjlokok
mkdir -p "${PREFIX}/bin"
mv ./scripts/* "${PREFIX}/bin/"
mv ./* "${PREFIX}/bin/"
pip install datasketch

exit 0
