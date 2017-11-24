#!/bin/bash
set -eu -o pipefail

gunzip -v *asn2gb.gz
mkdir -p "$PREFIX/bin"
cp *asn2gb $PREFIX/bin/asn2gb
chmod +x $PREFIX/bin/asn2gb

