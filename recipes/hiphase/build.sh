#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
# bioconda auto-extract for us apparently
# tar -xzf hiphase-*.tar.gz
md5sum -c hiphase.md5
cp hiphase "${PREFIX}"/bin/
