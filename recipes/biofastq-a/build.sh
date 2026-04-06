#!/bin/bash
set -euxo pipefail

cargo install --no-track --root "$PREFIX" --path .
