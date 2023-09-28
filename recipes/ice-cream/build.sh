#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
cp -r * ${PREFIX}/bin

chmod 0755 "${PREFIX}/bin/plotting_script.py"
chmod 0755 "${PREFIX}/bin/ICEcream.sh"
