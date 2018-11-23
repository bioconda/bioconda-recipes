#!/bin/bash

libstatgen_version=1.0.5
curl -o ../libStatGen-v"${libstatgen_version}".tar.gz -L https://github.com/statgen/libStatGen/archive/v"${libstatgen_version}".tar.gz

tar -xzf ../libStatGen-v"${libstatgen_version}".tar.gz -C ..
mv ../libStatGen-v"${libstatgen_version}" ../libStatGen

make

