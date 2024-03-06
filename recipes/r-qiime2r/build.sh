#!/usr/bin/env sh

set -o errexit
set -o pipefail


$R CMD INSTALL --build .
