#!/bin/bash

set -xe

# If the environment is arm64 architecture, set POPCNT_CAPABILITY to 0 and run make.
# This is because the POPCNT instruction is not supported on arm64 architecture.
# By setting POPCNT_CAPABILITY=0, this instruction is disabled, ensuring build compatibility.
# See https://github.com/BenLangmead/bowtie/blob/master/processor_support.h
if [ "$(uname -m)" == "arm64" ]; then
    make POPCNT_CAPABILITY=0 -j ${CPU_COUNT}
fi


make prefix="${PREFIX}"  -j ${CPU_COUNT} install

cp -r scripts "${PREFIX}/bin/"
