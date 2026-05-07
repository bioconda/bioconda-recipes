#!/bin/bash
set -e
export DISABLE_AUTOBREW=1

# 前回ビルドの残骸を削除
find . -name "*.o" -delete 2>/dev/null || true
find . -name "*.so" -delete 2>/dev/null || true

${R} CMD INSTALL --build .
