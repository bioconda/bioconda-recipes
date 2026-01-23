#!/bin/bash
set -eux
install -d "${PREFIX}/bin"
make -j "${CPU_COUNT}"
install -v -m 0755 rasbhari"${PREFIX}/bin"

