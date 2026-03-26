#!/bin/bash
set -xeuo pipefail

mkdir -p "${PREFIX}/bin"
install -m 0755 package/bin/seqera "${PREFIX}/bin/seqera"
