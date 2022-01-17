#!/bin/bash
echo Contents of /usr/local/include
ls -lah /usr/local/include || true
echo

echo Searching for htslib directory:
find /usr/local -name htslib || true
echo

cd bamcmp-2.1 || true
make CPP=$CC
cp build/bamcmp $PREFIX/bin
