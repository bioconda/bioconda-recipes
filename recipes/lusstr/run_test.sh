#!usr/bin/env bash
set -eo pipefail
pytest --cov=lusstr --pyargs lusstr
