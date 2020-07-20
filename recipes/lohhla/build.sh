#!/bin/bash

target=$PREFIX/bin/lohhla

mkdir -p ${PREFIX}/bin
echo "#!/usr/bin/env Rscript" > $target
cat LOHHLAscript.R >> $target
chmod +x $target
