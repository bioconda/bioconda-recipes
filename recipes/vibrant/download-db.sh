#!/usr/bin/env bash

echo "Downloading VIBRANT databases to ${VIBRANT_DATA_PATH}..."

# VIBRANT_DATA_PATH is defined in build.sh, store the db there

# use Python script to download and test data
cd ${VIBRANT_DATA_PATH}/databases
python VIBRANT_setup.py

echo "Testing VIBRANT databases..."
python VIBRANT_test_setup.py

echo "VIBRANT databases are downloaded successfully."

exit 0
