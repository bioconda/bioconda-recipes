#!/bin/bash
set -e
sed -i.bak "s#CONDA_PREFIX#PREFIX#g" setup.py

export CFLAGS="-Wno-incompatible-pointer-types -falign-functions=8 -march=armv8-a -std=c99"

if [[ ${target_platform}  == "linux-aarch64" ]]; then
 sed -i "40c \\\t                                         ids=ids,taxa=taxa," unifrac/tests/test_api.py
 sed -i "60c \\\t                                         ids=ids,taxa=taxa," unifrac/tests/test_api.py
 sed -i "80c \\\t                                         ids=ids,taxa=taxa," unifrac/tests/test_api.py
 sed -i "105c \\\t                                         ids=ids,taxa=taxa," unifrac/tests/test_api.py
 
 sed -i "37a \\\        taxa = table.ids(axis='observation')"  unifrac/tests/test_api.py
 sed -i "58a \\\        taxa = table.ids(axis='observation')"  unifrac/tests/test_api.py
 sed -i "78a \\\        taxa = table.ids(axis='observation')"  unifrac/tests/test_api.py
 sed -i "104a \\\        taxa = table_inmem.ids(axis='observation')"  unifrac/tests/test_api.py
fi

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
