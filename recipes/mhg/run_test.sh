#!/usr/bin/env bash
# stop on error
set -eu -o pipefail

MHG -g genomes/ -t 0.95
