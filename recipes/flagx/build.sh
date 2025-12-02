#!/usr/bin/env bash
set -euxo pipefail

pip install . --no-deps -vv
pip install flowio flowutils --no-deps -vv
