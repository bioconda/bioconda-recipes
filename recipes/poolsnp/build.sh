#! /bin/bash

set -ex

BASE_DIR=$(dirname "$0")
SCRIPTS_DIR="$BASE_DIR/scripts"
TEST_DATA_DIR="$BASE_DIR/TestData"

# Check for scripts directory
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "The scripts directory is missing. It should be placed in the same directory as the PoolSNP.sh script."
    exit 1
fi

# Check for TestData directory
if [ ! -d "$TEST_DATA_DIR" ]; then
    echo "The TestData directory is missing. It should be placed in the same directory as the PoolSNP.sh script."
    exit 1
fi

chmod +x PoolSNP.sh

mkdir -p $PREFIX/bin

cp PoolSNP.sh $PREFIX/bin
cp -r $SCRIPTS_DIR $PREFIX/bin

mkdir -p $PREFIX/share/PoolSNP

# Copy the test data to the share directory
cp -r $TEST_DATA_DIR $PREFIX/share/PoolSNP/TestData