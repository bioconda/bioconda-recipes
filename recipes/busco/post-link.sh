#!/bin/bash

# BUSCO needs a config file with paths to external dependencies. These deps are
# installed as runtime deps, but the paths in the config file need to reflect
# the current environment's $PREFIX/bin dir. BUSCO expects a config file in
# ../config/config.ini, so we create it here using sed on the default ini
# stored in the share dir, replacing paths as necessary.
SHARE="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$PREFIX/config"
sed "s|^path = .*\$|path = $PREFIX/bin/|" "$SHARE/config.ini.default" > "$PREFIX/config/config.ini"
