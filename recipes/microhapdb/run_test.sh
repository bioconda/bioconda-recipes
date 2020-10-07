#!/usr/bin/env bash
set -eo pipefail
pytest --cov=microhapdb --pyargs microhapdb --doctest-modules
