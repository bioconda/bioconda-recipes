#!/usr/bin/env bash

echo -e "\n\n*** TEST ***\n\n"
pytest -v --ignore tests/test_sapi_enzyme_restriction_site.py --ignore tests/test_circular_sequences/test_circular_sequences.py