#!/bin/bash
set -euxo pipefail

export CGO_ENABLED=0
export GOTOOLCHAIN=local
export GOFLAGS=-modcacherw
export GOPATH="${SRC_DIR}/.gopath"
export GOCACHE="${SRC_DIR}/.cache"

mkdir -p "${PREFIX}/bin"
go build -trimpath -o "${PREFIX}/bin/hapiq" \
  -ldflags "-s -w -X github.com/btraven00/hapiq/internal/version.Version=${PKG_VERSION}" .

# Third-party licenses of the statically linked Go modules.
go-licenses save . --save_path="${SRC_DIR}/library_licenses" --ignore github.com/btraven00/hapiq
