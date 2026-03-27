#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
# bioconda auto-extract for us apparently
# tar -xzf methbat-*.tar.gz
md5sum -c methbat.md5
cp methbat "${PREFIX}"/bin/
