#!/bin/bash

set -xe

mkdir -p "${{PREFIX}}/bin"
cp -f kent/src/utils/{program} "${{PREFIX}}/bin"
chmod 0755 "${{PREFIX}}/bin/{program}"
