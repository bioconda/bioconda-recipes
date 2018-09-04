#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
cp ccs "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/ccs

# install disclaimer
cp .messages.txt "${PREFIX}"/
