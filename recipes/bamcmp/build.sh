#!/bin/bash

ls -lah /usr/local/include/htslib || true

cd bamcmp-2.1 || true
make CPP=$CC
cp build/bamcmp $PREFIX/bin
