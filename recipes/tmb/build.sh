#!/bin/bash

set -eo pipefail

mkdir -p  "${PREFIX}/bin" "${PREFIX}/config" "${PREFIX}/test"

mv */bin/* "${PREFIX}/bin"
mv */config/* "${PREFIX}/config"
mv */test/* "${PREFIX}/test"
chmod +x bin/*