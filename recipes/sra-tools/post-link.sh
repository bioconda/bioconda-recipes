#!/bin/bash

#  sra-toolkit >= 2.10.2 requires a config dotfile to exist with a GUID
#
# See:
#   https://www.ncbi.nlm.nih.gov/sra/docs/sra-cloud/
#   https://github.com/ncbi/sra-tools/blob/master/build/docker/Dockerfile
#   https://github.com/ncbi/sra-tools/issues/291
#   https://github.com/ncbi/sra-tools/issues/282
#   https://github.com/ncbi/sra-tools/blob/9ea223545e34f4af7c722759764361a7bee84a45/tools/driver-tool/sratools.cpp#L155
#   https://github.com/ncbi/sra-tools/blob/9ea223545e34f4af7c722759764361a7bee84a45/tools/driver-tool/config.hpp#L46-L64

if ! grep "/LIBS/GUID" ~/.ncbi/user-settings.mkfg &> /dev/null; then
    echo "No entry for '/LIBS/GUID' in ~/.ncbi/user-settings.mkfg; adding..."
    mkdir -p ~/.ncbi
    printf '/LIBS/GUID = "%s"\n' `uuidgen` >> ~/.ncbi/user-settings.mkfg
else
    echo "~/.ncbi/user-settings.mkfg has entry for '/LIBS/GUID'; continuing..."
fi