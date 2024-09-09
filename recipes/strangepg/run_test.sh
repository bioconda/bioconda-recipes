#!/bin/sh -e
# https://github.com/bioconda/bioconda-recipes/pull/29042#issuecomment-864465780

strpg -h 2>/dev/null
strpg /dev/mordor 2>/dev/null || [[ $? == 1 ]]
echo | strawk -f cmd/main.awk
