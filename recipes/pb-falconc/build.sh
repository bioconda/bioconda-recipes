#!/bin/bash
set -vxeu -o pipefail

make rsync
make test
#R=$(git rev-parse HEAD) make build
make build
make install
