#!/bin/bash
set -eu -o pipefail

cd src
make
make install
