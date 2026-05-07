#!/bin/bash

set -ex

# 设置 Rust 编译环境变量
export CARGO_HOME=$BUILD_PREFIX/cargo
mkdir -p $CARGO_HOME

# 1. 确保 bindgen 找到 libclang
export LIBCLANG_PATH=$BUILD_PREFIX/lib

# 2. 关键修复：让 rust-htslib 链接到 conda 环境提供的库，而不是系统库
# 设置 HTSLIB 链接路径
export HTSLIB_INCLUDE_DIR=$PREFIX/include
export HTSLIB_LIBRARY_DIR=$PREFIX/lib

# 3. 强制 hts-sys 静态编译它自带的源码
# 这是解决 "no field block_address" 错误的最彻底方法
# 因为 1.0.0 版本的 rust-htslib 与 Conda 环境中某些版本的 htslib 可能存在 API 微差
export HTSLIB_LOCAL=1

# 编译并安装
cargo install --locked --root $PREFIX --path .

# 清理
rm -f $PREFIX/.crates.toml $PREFIX/.crates2.json
