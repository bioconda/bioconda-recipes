#!/bin/bash
set -eu -o pipefail

mkdir -p "$PREFIX/bin"
ls -al
cp *asn2gb $PREFIX/bin/asn2gb
chmod +x $PREFIX/bin/asn2gb

