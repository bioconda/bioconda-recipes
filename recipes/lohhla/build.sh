#!/bin/bash

target=$PREFIX/bin/lohhla

echo "#!/usr/bin/env Rscript" > $target
cat LOHHLAscript.R >> $target
chmod +x $target
