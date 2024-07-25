#!/bin/bash
make -j${CPU_COUNT} LEIDEN=true
install -d "${PREFIX}/bin"
install clusty "${PREFIX}/bin"
