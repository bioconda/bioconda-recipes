#!/bin/bash
set -eu -o pipefail

make build
make install
