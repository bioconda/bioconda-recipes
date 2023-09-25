#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
# bioconda auto-extract for us apparently
# tar -xzf hificnv-*.tar.gz
md5sum -c hificnv.md5
cp hificnv "${PREFIX}"/bin/
