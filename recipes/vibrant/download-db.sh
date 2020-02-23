#!/usr/bin/env bash


if [[ ! -z "$1" ]];
then

echo "Set VIBRANT_DATA_PATH to $1 "

sleep 2s
mkdir -p $1


cp -r $VIBRANT_DATA_PATH/* $1/

export VIBRANT_DATA_PATH=$1

cat <<EOF >> ${PREFIX}/etc/conda/activate.d/vibrant.sh
export VIBRANT_DATA_PATH=${VIBRANT_DATA_PATH}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/vibrant.sh
unset VIBRANT_DATA_PATH
EOF

fi

echo "Downloading VIBRANT databases to ${VIBRANT_DATA_PATH}..."

# VIBRANT_DATA_PATH is defined in build.sh, store the db there


# use Python script to download and test data
cd ${VIBRANT_DATA_PATH}/databases
python VIBRANT_setup.py

echo "Testing VIBRANT databases..."
python VIBRANT_test_setup.py

echo "VIBRANT databases are downloaded successfully."

exit 0
