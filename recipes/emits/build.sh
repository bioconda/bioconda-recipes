#!/bin/bash
set -euo pipefail

cargo build --release
mkdir -p $PREFIX/bin
cp target/release/emits $PREFIX/bin/