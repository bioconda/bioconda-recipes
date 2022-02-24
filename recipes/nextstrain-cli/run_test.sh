#!/bin/bash
set -euo pipefail -x

nextstrain --help
nextstrain check-setup || true

git clone https://github.com/nextstrain/zika-tutorial
nextstrain build --native --cpus 1 zika-tutorial
