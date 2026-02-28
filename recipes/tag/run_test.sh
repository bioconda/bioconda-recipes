#!/usr/bin/env bash
set -eo pipefail
pytest --cov=tag --pyargs tag
