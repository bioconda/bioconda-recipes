#!/bin/bash
set -euo pipefail

RUST_BACKTRACE=1 cargo install --no-track --verbose --root "${PREFIX}" --path crates/cyto
