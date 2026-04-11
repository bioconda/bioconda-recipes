#!/bin/bash
set -euxo pipefail

cargo build --release 2>&1
install -m755 target/release/biofastq-a "$PREFIX/bin/biofastq-a"
