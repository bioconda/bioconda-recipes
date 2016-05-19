#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
cp OMG.jar $PREFIX/bin/omg
chmod 0755 "${PREFIX}/bin/omg"

