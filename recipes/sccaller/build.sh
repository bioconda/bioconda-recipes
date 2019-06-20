#!/bin/bash
set -eu -o pipefail

SHARE=share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/$SHARE
mkdir -p $PREFIX/bin

# TODO: substitute `v1.2` with variable or remove, depending on upstream decision at <https://github.com/biosinodx/SCcaller>
cp $SRC_DIR/${PKG_NAME}_v1.2.py $PREFIX/$SHARE/${PKG_NAME}_v1.2.py

echo "#!/usr/bin/env bash" >$PREFIX/bin/sccaller
# TODO: substitute `v1.2` with variable or remove, depending on upstream decision at <https://github.com/biosinodx/SCcaller>
echo "python2.7 $PREFIX/$SHARE/${PKG_NAME}_v1.2.py \$@" >>$PREFIX/bin/sccaller
chmod 0755 "${PREFIX}/bin/sccaller"
