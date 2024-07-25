#!/bin/bash
make -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install clusty "${PREFIX}/bin"
