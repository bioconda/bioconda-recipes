#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin
cp ICEcream.sh ${PREFIX}/bin/ICEcream.sh
cp ICEfamily_refer/familytools/plotting_script.py ${PREFIX}/bin/plotting_script.py

chmod 0755 "${PREFIX}/bin/plotting_script.py"
chmod 0755 "${PREFIX}/bin/ICEcream.sh"