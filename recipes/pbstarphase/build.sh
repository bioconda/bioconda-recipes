#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
# bioconda auto-extract for us apparently
# tar -xzf pbstarphase-*.tar.gz
md5sum -c pbstarphase.md5
cp pbstarphase "${PREFIX}"/bin/
