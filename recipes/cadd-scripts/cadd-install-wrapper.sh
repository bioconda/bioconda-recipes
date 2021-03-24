# Wrapper for CADD.sh
set -eu -o pipefail

CADD=$PACKAGE_HOME \
    $PACKAGE_HOME/install.sh "$@"
