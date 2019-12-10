#!/bin/bash

# BUSCO needs a config file with paths to external dependencies. These deps are
# installed as runtime deps, but the paths in the config file need to reflect
# the current environment's $PREFIX/bin dir. BUSCO expects a config file in
# ../config/config.ini, so we create it here using busco_configurator.py on the default ini
# stored in the share dir, replacing paths as necessary.
SHARE="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$PREFIX/config"
python3 $PREFIX/bin/busco_configurator.py "$SHARE/config.ini.default" "$PREFIX/config/config.ini"

# This should not be necessary in v4.0.beta2
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat "export BUSCO_CONFIG_FILE=$PREFIX/config/config.ini" >> ${PREFIX}/etc/conda/activate.d/set_busco_variable.sh
cat "unset BUSCO_CONFIG_FILE" >> ${PREFIX}/etc/conda/deactivate.d/set_busco_variable.sh
