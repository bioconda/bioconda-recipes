#!/usr/bin/env bash
set -euxo pipefail

export CGO_ENABLED=0
# Reproducible builds; use vendor mode only if vendor/ exists.
export GOFLAGS="${GOFLAGS:-} -trimpath -buildvcs=false"
if [ -d vendor ]; then
  export GOFLAGS="$GOFLAGS -mod=vendor"
fi

mkdir -p "${PREFIX}/bin"
go version
go build -o "${PREFIX}/bin/ipcr" ./cmd/ipcr

# smoke test
"${PREFIX}/bin/ipcr" --help >/dev/null
