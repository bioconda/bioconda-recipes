#!/bin/bash

set -xe

mkdir -p "$PREFIX/bin"
cp {program_source_dir}/{program} "${{PREFIX}}/bin"
chmod 0755 "${{PREFIX}}/bin/{program}"
