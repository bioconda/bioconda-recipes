#!/usr/bin/env bash
set -eo pipefail
pytest --pyargs scirpy -m conda
