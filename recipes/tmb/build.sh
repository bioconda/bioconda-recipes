#!/bin/bash
set -eo pipefail

mkdir -p  "${PREFIX}/bin" "${PREFIX}/config" "${PREFIX}/test"

ls -l *

install -v -m 0755 bin/*.py "${PREFIX}/bin"
mv config/*.yml "${PREFIX}/config/"
mv test/* "${PREFIX}/test/"
