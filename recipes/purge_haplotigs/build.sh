#!/bin/bash
set -eo pipefail

mkdir -p  "${PREFIX}/bin" "${PREFIX}/scripts" "${PREFIX}/lib" "${PREFIX}/test"

mv bin/* "${PREFIX}/bin"
mv scripts/* "${PREFIX}/scripts"
mv lib/* "${PREFIX}/lib"
mv test/* "${PREFIX}/test"

purge_haplotigs help

