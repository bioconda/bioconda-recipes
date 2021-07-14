#!/bin/bash
install -d "${PREFIX}/bin"
install probeit.py "${PREFIX}/bin/"
cd setcover
make -j $CPU_COUNT
install setcover "${PREFIX}/bin/"
