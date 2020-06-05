#!/usr/bin/env bash
set -eo pipefail
pytest --cov=microhapulator --pyargs microhapulator
