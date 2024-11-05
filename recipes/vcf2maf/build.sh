#!/bin/bash -euo

mkdir -p ${PREFIX}/bin
chmod +x *.pl && cp -f *.pl ${PREFIX}/bin
