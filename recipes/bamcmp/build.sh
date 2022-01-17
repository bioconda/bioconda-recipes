#!/bin/bash
echo Contents of /usr/local
ls -lah /usr/local || true
echo

echo Searching for sam.h file:
find / -name sam.h || true
echo

cd bamcmp-2.1 || true
make CPP=$CC
cp build/bamcmp $PREFIX/bin
