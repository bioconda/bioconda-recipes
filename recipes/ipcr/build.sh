#!/usr/bin/env bash
set -euo pipefail

export CGO_ENABLED=0
export GO111MODULE=on
export GOCACHE="$PWD/.cache"

mkdir -p "${GOCACHE}" "${PREFIX}/bin"

go version

LDFLAGS="-s -w -X ipcr/internal/version.Version=v${PKG_VERSION}"

go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/ipcr"            ./cmd/ipcr
go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/ipcr-probe"      ./cmd/ipcr-probe
go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/ipcr-nested"     ./cmd/ipcr-nested
go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/ipcr-multiplex"  ./cmd/ipcr-multiplex
go build -tags thermo -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/ipcr-thermo" ./cmd/ipcr-thermo
