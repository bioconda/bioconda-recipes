#!/bin/bash
set -euo pipefail -x

nextstrain --help
nextstrain check-setup || true
