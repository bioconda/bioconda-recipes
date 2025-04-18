#!/bin/bash

mkdir -p ${PREFIX}/bin
cp PanDepth-${PKG_VERSION}-Linux-x86_64/pandepth ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/pandepth
