#!/bin/bash

set -euxo pipefail

"${PYTHON}" -m pip install . --no-deps -vv

mkdir -p $PREFIX/bin/
cp bin/busco $PREFIX/bin/busco #python script
cp scripts/generate_plot.py $PREFIX/bin/generate_plot.py
cp scripts/busco_configurator.py $PREFIX/bin/busco_configurator.py


# BUSCO needs a config file with paths to external dependencies. These deps are
# installed as runtime deps, but the paths in the config file need to reflect
# the current environment's $PREFIX/bin dir. BUSCO expects a config file in,
# so we create it here using busco_configurator.py on the default ini
# stored in the share dir, replacing paths as necessary.

SHARE="${PREFIX}/share/busco"
mkdir -p "${SHARE}"
busco_configurator.py "config/config.ini" "${SHARE}/config.ini"
