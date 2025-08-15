#!/usr/bin/env bash

set -xe
pytest -v tests/ --cov
