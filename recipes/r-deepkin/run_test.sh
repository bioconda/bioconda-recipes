#!/usr/bin/env bash
set -euo pipefail

# Minimal test: ensure the package loads successfully using the R interpreter.
R -q -e "library('deepKin')"