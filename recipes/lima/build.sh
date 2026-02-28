#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
cp lima lima-undo "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/lima "${PREFIX}"/bin/lima-undo
