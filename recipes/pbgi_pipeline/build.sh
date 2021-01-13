#!/bin/sh
set -e

echo sjlokok
mkdir -p "${PREFIX}/bin"
mv ./scripts/* "${PREFIX}/bin/"
mv ./* "${PREFIX}/bin/"
pip list
# pip install -i https://pypi.tuna.tsinghua.edu.cn/simple datasketch
pip install datasketch -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn

exit 0
