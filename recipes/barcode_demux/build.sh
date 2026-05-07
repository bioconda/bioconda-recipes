#!/bin/bash

set -ex

# 设置 Rust 编译环境变量
export CARGO_HOME=$BUILD_PREFIX/cargo
mkdir -p $CARGO_HOME

# 关键修复：让 bindgen 找到 libclang
export LIBCLANG_PATH=$BUILD_PREFIX/lib

# 强制链接到 Conda 提供的外部 htslib
export HTSLIB_INCLUDE_DIR=$PREFIX/include
export HTSLIB_LIBRARY_DIR=$PREFIX/lib

# 编译并安装到 Conda 环境的 bin 目录
cargo install --locked --root $PREFIX --path .

# 清理不需要的 cargo 元数据
rm -f $PREFIX/.crates.toml $PREFIX/.crates2.json
