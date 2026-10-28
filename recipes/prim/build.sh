#!/bin/bash
set -xe

export GOPATH="${SRC_DIR}/gopath"
export GOCACHE="${SRC_DIR}/.gocache"
mkdir -p "${GOPATH}" "${GOCACHE}" "${PREFIX}/bin"

# Build each program directly rather than via the upstream Makefile: its rules try to
# re-tangle the .go files from .org with noweb/notangle and clobber them when notangle
# is absent, and `make test` wants to wget test data.
LDFLAGS_GO="-X github.com/evolbioinf/prim/util.version=${PKG_VERSION}"
LDFLAGS_GO="${LDFLAGS_GO} -X github.com/evolbioinf/prim/util.date=2026-03-04"

for prog in cops fa2prim prim2tab scop; do
    go build -trimpath -buildvcs=false -ldflags "${LDFLAGS_GO}" \
        -o "${PREFIX}/bin/${prog}" "./${prog}"
    chmod +x "${PREFIX}/bin/${prog}"
done
