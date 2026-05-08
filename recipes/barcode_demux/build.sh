#!/bin/bash

set -ex

# 1. 设置 Rust 环境
export CARGO_HOME=$BUILD_PREFIX/cargo
mkdir -p $CARGO_HOME

# 2. 让 bindgen 能够解析头文件成员的关键修复
# 指向 clang 本身
export CLANG_PATH=$BUILD_PREFIX/bin/clang
# 指向 libclang 路径
export LIBCLANG_PATH=$BUILD_PREFIX/lib
# 强制让 bindgen 搜索 Conda 环境中的头文件目录（解决 opaque struct 问题）
export CPATH="$PREFIX/include:$BUILD_PREFIX/include"

# 3. 链接到 Conda 提供的外部 htslib
export HTSLIB_INCLUDE_DIR=$PREFIX/include
export HTSLIB_LIBRARY_DIR=$PREFIX/lib

# 4. 执行编译
cargo install --locked --root $PREFIX --path .

# 5. 清理
rm -f $PREFIX/.crates.toml $PREFIX/.crates2.json
