#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
cp isoseq "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/isoseq
rm -rf "${PREFIX}"/bin/isoseq3
ln -s "${PREFIX}"/bin/isoseq "${PREFIX}"/bin/isoseq3
