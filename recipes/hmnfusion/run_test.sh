#!/usr/bin/env bash

echo -e "\n\n*** TEST ***\n\n"
hmnfusion version
pytest -v tests/
