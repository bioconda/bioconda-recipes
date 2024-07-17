#!/bin/bash

set -xe

make famsa -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install famsa "${PREFIX}/bin"
