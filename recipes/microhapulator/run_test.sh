#!/usr/bin/env bash
set -eo pipefail
pytest -k "not pipe" --pyargs microhapulator
