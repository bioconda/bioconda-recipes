#!/bin/sh
set -eu

$PYTHON -m pip install . --no-deps -vv

curl --output "v${PKG_VERSION}.tar.gz" -L "https://github.com/RIVM-bioinformatics/auriclass/archive/v${PKG_VERSION}.tar.gz"

tar zxvf "v${PKG_VERSION}.tar.gz"

cp -r "auriclass-${PKG_VERSION}/data" "${PREFIX}/data"

rm -rf "v${PKG_VERSION}.tar.gz" "auriclass-${PKG_VERSION}"
