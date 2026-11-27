#!/bin/bash
set -euxo pipefail

# Upstream test on the bundled example data (needs test/source_files and pytest)
pytest -v tests
