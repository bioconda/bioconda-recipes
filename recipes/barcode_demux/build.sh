#!/bin/bash

set -ex

# 设置 Rust 编译环境变量
export CARGO_HOME=$BUILD_PREFIX/cargo
mkdir -p $CARGO_HOME

# 关键：让 bindgen 找到编译环境中的 libclang
export LIBCLANG_PATH=$BUILD_PREFIX/lib

# 关键：强制 rust-htslib 使用其自带的 HTSlib 源码进行静态编译
# 这样可以完美解决字段找不到的冲突问题
export HTSLIB_LOCAL=1

# 编译并安装到 Conda 环境的 bin 目录
cargo install --locked --root $PREFIX --path .

# 清理不需要的 cargo 元数据
rm -f $PREFIX/.crates.toml $PREFIX/.crates2.json
