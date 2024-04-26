#!/bin/bash

perl Makefile.PL
make

# Copy over the executables
mkdir -p ${PREFIX}/bin 
find scripts SneakerNet.plugins -maxdepth 1 -type f | \
  xargs -n 1 -P 1 bash -c '
    chmod -v 775 $0;
    cp -v $0 ${PREFIX}/bin/
  '

