#!/bin/bash
set -e

gunzip $SRC_DIR/*tbl2asn.gz
mkdir -p "$PREFIX/bin"
cp "$SRC_DIR"/*.tbl2asn "$PREFIX/bin/tbl2asn"
chmod +x "$PREFIX/bin/tbl2asn"
