#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin"
cp kent/src/utils/bedJoinTabOffset "${PREFIX}/bin"
chmod 0755 "${PREFIX}/bin/bedJoinTabOffset"
