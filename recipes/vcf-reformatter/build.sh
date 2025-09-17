#!/bin/bash
set -euxo pipefail

# Install using cargo
cargo install --locked --root $PREFIX --path .
