#! /bin/bash

set -ex

BASE_DIR=$(dirname "$0")
SCRIPTS_DIR="${BASE_DIR}/scripts"
TEST_DATA_DIR="${BASE_DIR}/TestData"

if [ ! -d "${SCRIPTS_DIR}" ]; then
    echo "The scripts directory is missing. It should be placed in the same directory as the PoolSNP.sh script."
    exit 1
fi

if [ ! -d "${TEST_DATA_DIR}" ]; then
    echo "The TestData directory is missing. It should be placed in the same directory as the PoolSNP.sh script."
    exit 1
fi

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/scripts
mkdir -p ${PREFIX}/share/PoolSNP

cp PoolSNP.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/PoolSNP.sh

for script in $SCRIPTS_DIR/*; do

    cp $script ${PREFIX}/bin/scripts/
    chmod +x ${PREFIX}/bin/scripts/$(basename $script)

    # The main script PoolSNP.sh relies on the scripts being in the same directory as it
    # Modifying PoolSNP.sh to update the path to the scripts
    script_name=$(basename $script)

    sed -i.bak "s|${script_name}|\\\$(which ${script_name})|g" ${PREFIX}/bin/PoolSNP.sh

done

cp -r ${TEST_DATA_DIR} ${PREFIX}/share/PoolSNP/TestData