#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
# bioconda auto-extract for us apparently
# tar -xzf mitorsaw-*.tar.gz
md5sum -c mitorsaw.md5
cp mitorsaw "${PREFIX}"/bin/
