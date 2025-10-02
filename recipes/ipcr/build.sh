#!/usr/bin/env bash
set -euxo pipefail

export CGO_ENABLED=0
export GOFLAGS="${GOFLAGS:-} -trimpath -buildvcs=false"
if [ -d vendor ]; then
  export GOFLAGS="$GOFLAGS -mod=vendor"
fi

mkdir -p "${PREFIX}/bin"
go version
go build -o "${PREFIX}/bin/ipcr" ./cmd/ipcr

# smoke test: use a zero-exit flag
"${PREFIX}/bin/ipcr" --version >/dev/null
# if you want to keep a help check too, do it non-fatal:
# "${PREFIX}/bin/ipcr" --help >/dev/null 2>&1 || true
