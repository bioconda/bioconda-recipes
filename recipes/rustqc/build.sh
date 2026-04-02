#!/bin/bash
set -xeuo pipefail

mkdir -p "${PREFIX}/bin"
install -m 0755 rustqc-*/rustqc "${PREFIX}/bin/rustqc"
