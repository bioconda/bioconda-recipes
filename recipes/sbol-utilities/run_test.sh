#!/usr/bin/env bash

echo -e "\n\n*** TEST ***\n\n"
pytest --ignore=test/test_docstr_coverage.py --ignore=test/test_graph_sbol.py -sv
