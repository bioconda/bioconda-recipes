#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin/
cp *mtgrasp* ${PREFIX}/bin/
cp -r data ${PREFIX}/bin/
cp -r test ${PREFIX}/bin/
