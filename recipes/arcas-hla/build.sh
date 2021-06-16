#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

cp -r dat scripts test LICENSE README.md arcasHLA $PACKAGE_HOME

cat >$PREFIX/bin/arcasHLA <<EOF
#!/bin/bash
#
# Simple wrapper script for arcasHLA.

set -euo pipefail

$PACKAGE_HOME/arcasHLA \$@
EOF
chmod a+rx $PREFIX/bin/arcasHLA 
