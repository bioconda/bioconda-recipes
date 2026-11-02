#!/bin/bash
set -xeuo pipefail

mkdir -p "${PREFIX}/bin"
install -m 0755 bin/seqera "${PREFIX}/bin/seqera"
