#!/bin/bash

set -eo pipefail

mkdir -p  "${PREFIX}/bin" "${PREFIX}/config" "${PREFIX}/test"

ls -l *
mv bin/*.py "${PREFIX}/bin/"
mv config/*.yml "${PREFIX}/config/"
mv test/* "${PREFIX}/test/"
chmod 0755 ${PREFIX}/bin/*.py
chmod +x ${PREFIX}/bin/*.py