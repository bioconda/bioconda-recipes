#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
cp ccs ccs-alt "${PREFIX}"/bin/
chmod +x "${PREFIX}"/bin/ccs "${PREFIX}"/bin/ccs-alt
