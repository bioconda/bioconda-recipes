#!/bin/sh
set -e

echo sjlokok
mkdir -p "${PREFIX}/bin"
mv ./scripts/* "${PREFIX}/bin/"
mv ./* "${PREFIX}/bin/"
pip list
# pip install -i https://pypi.tuna.tsinghua.edu.cn/simple datasketch
pip --trusted-host https://pypi.tuna.tsinghua.edu.cn/simple install datasketch

exit 0
