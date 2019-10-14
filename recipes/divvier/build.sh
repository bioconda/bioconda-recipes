#!/bin/bash
set -eu -o pipefail
make

mkdir -p ${PREFIX}/bin
cp ./divvier ${PREFIX}/bin/
