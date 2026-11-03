#!/bin/bash
make protestar -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install protestar "${PREFIX}/bin"


