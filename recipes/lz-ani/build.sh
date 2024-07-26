#!/bin/bash
make -j${CPU_COUNT} CC=${CC}
install -d "${PREFIX}/bin"
install lz-ani "${PREFIX}/bin"
