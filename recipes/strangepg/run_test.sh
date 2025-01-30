#!/bin/sh -e
# https://github.com/bioconda/bioconda-recipes/pull/29042#issuecomment-864465780

strangepg -h 2>/dev/null
strangepg -D load test/frag10.gfa 2>/dev/null
