#!/bin/sh
set -e

echo sjlokok
mkdir -p "${PREFIX}/bin"
mv ./scripts/* "${PREFIX}/bin/"
mv ./* "${PREFIX}/bin/"
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple datasketch

exit 0
