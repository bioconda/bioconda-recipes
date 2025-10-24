#!/bin/bash
python -m pip install . --no-deps --no-build-isolation --ignore-installed --no-cache-dir -vvv
${PREFIX}/bin/sistr_init
