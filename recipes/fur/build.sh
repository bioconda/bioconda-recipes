#!/bin/bash
set -euxo pipefail

export GOTOOLCHAIN=local
export CGO_ENABLED=1
make -j"${CPU_COUNT:-1}" version="v4.3" date="$(date +%Y-%m-%d)"

install -d "${PREFIX}/bin"
install -m 0755 bin/cleanSeq "${PREFIX}/bin/cleanSeq"
install -m 0755 bin/fur "${PREFIX}/bin/fur"
install -m 0755 bin/madis "${PREFIX}/bin/madis"
install -m 0755 bin/makeFurDb "${PREFIX}/bin/makeFurDb"
install -m 0755 bin/stream "${PREFIX}/bin/stream"
