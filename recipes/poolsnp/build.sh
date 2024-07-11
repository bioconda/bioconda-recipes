#! /bin/bash

set -ex

BASE_DIR=$(dirname "$0")
SCRIPTS_DIR="$BASE_DIR/scripts"

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "The scripts directory is missing. It should be placed in the same directory as the PoolSNP.sh script."
    exit 1
fi

chmod +x PoolSNP.sh

cp PoolSNP.sh $PREFIX/bin
cp -r $SCRIPTS_DIR $PREFIX/bin

chmod +x $PREFIX/bin/PoolSNP.sh