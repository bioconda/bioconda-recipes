#!/bin/bash
set -eo pipefail

# 环境变量配置
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"
export CFLAGS="-std=gnu11 -Wno-deprecated-declarations"
export CXXFLAGS="-std=gnu++14"
export RUSTFLAGS="-C link-arg=-Wl,--allow-multiple-definition"
export CC=/usr/bin/aarch64-linux-gnu-gcc
export CXX=/usr/bin/aarch64-linux-gnu-g++


RUST_BACKTRACE=1 cargo install \
  --verbose \
  --path . \
  --root "${PREFIX:-/usr/local}" \
  --target aarch64-unknown-linux-gnu


# 增强版源码定位逻辑
find_mimalloc_src() {
  local search_paths=(
    "${CARGO_HOME}/registry/src/"
    "${HOME}/.cargo/registry/src/"
    "/usr/local/cargo/registry/src/"
  )

  for path in "${search_paths[@]}"; do
    if [ -d "$path" ]; then
      MIMALLOC_SRC=$(find "$path" -path "*/mimalloc*/src" -print -quit)
      [ -n "$MIMALLOC_SRC" ] && return 0
    fi
  done
  return 1
}

# 安全替换函数
safe_sed_replace() {
  local file=$1 pattern=$2 replacement=$3
  perl -i -pe "s|${pattern}|${replacement}|g" "$file"
}

# 主流程
if ! find_mimalloc_src; then
  echo "[ERROR] mimalloc源码定位失败，尝试运行: cargo fetch" >&2
  exit 1
fi

echo "找到mimalloc源码: $MIMALLOC_SRC"

# 原子操作修复
safe_sed_replace "$MIMALLOC_SRC/os.c" \
  'ATOMIC_VAR_INIT$([^)]+)$' \
  '\1'

safe_sed_replace "$MIMALLOC_SRC/init.c" \
  'ATOMIC_VAR_INIT$0$' \
  '0'

safe_sed_replace "$MIMALLOC_SRC/init.c" \
  'ATOMIC_VAR_INIT$NULL$' \
  'NULL'

# 构建流程
cargo clean
RUST_BACKTRACE=1 cargo install \
  --verbose \
  --path . \
  --root "${PREFIX:-/usr/local}" \
  --target aarch64-unknown-linux-gnu
