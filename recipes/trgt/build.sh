#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
gunzip *.gz
mv trvz* trvz
mv trgt* trgt
chmod +x trvz
chmod +x trgt
cp trvz "${PREFIX}"/bin/
cp trgt "${PREFIX}"/bin/

