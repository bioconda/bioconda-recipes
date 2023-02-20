#!/bin/bash

# call installer
chmod u+x MALT_unix_0_6_1.sh
MALT="$PREFIX/opt/$PKG_NAME-$PKG_VERSION"
./MALT_unix_0_6_1.sh -q -dir "$MALT"

# use the javafx library installed by conda
rm -r "${OUT}/jars/libs/modules/"

ln -s "$MALT"/malt-build "$PREFIX"/bin/malt-build
ln -s "$MALT"/malt-run "$PREFIX"/bin/malt-run
