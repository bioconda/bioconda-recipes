#!/usr/bin/env bash
set -eo pipefail

pytest --cov=rsidx --doctest-modules --pyargs rsidx
