#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"
cp kent/src/utils/webSync "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/webSync"
