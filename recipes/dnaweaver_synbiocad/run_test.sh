#!/usr/bin/env bash

echo -e "\n\n*** TEST ***\n\n"
python -m dnaweaver_synbiocad --help
pytest -v