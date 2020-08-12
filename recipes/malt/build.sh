#!/bin/bash

# call installer
chmod u+x MALT_unix_0_4_1.sh
MALT="$PREFIX/opt/$PKG_NAME-$PKG_VERSION"
./MALT_unix_0_4_1.sh -q -dir "$MALT"

ln -s "$MALT"/malt-build "$PREFIX"/bin/malt-build
ln -s "$MALT"/malt-run "$PREFIX"/bin/malt-run
