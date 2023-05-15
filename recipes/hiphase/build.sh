#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
tar -xzf hiphase-v${VERSION}-x86_64-unknown-linux-gnu.tar.gz
cp hiphase-v${VERSION}-x86_64-unknown-linux-gnu/hiphase "${PREFIX}"/bin/
